import os
import boto3
from botocore.exceptions import ClientError
import datetime
import dateutil.tz
import dateutil.parser
import json


#### Lambda function for SNS notifications
####
#### Purpose:  Have the ability to easily(as possible) add mulitple emails to SNS
####
#### This function is used in lambda function created by CloudFormation
#### The Lambda function will be subscribed to to the SNS topic and
#### will process the SNS event, pull out the SNS message, format the
#### information in an email message and be sent to the recepients.
####

# This is the 'from address that lambda is going to send from
# This address must be verified with Amazon SES.
SENDER = "katt-automation-toolsadm@list.arizona.edu"

# ADD NEW EMAILS HERE AS NEEDED.
RECIPIENT = ["katt-automation-toolsadm@list.arizona.edu", "ua_met_app@tbginc.com"]

# If necessary, replace us-west-2 with the AWS Region you're using for Amazon SES.
AWS_REGION = "us-west-2"

# Convert a datetime object into milleseconds from the unix epoch
def unix_time_millis(dt):
    epoch = datetime.datetime.fromtimestamp(0, dateutil.tz.gettz('UTC') )
    return int( (dt - epoch).total_seconds() * 1000.0 )

# The character encoding for the email.
CHARSET = "UTF-8"

# set up a date value
DATE = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")

# Create a new SES(aws email)  resource and specify a region.
ses = boto3.client('ses',region_name=AWS_REGION)

# Send Email function
def send_email(EMAIL_BODY_HTML,EMAIL_BODY_TXT,SUBJECT):
    # Try to send the email.
    try:
        for email in RECIPIENT:
            #Provide the contents of the email.
            response = ses.send_email(
                Destination={
                    'ToAddresses': [
                        email,
                    ],
                },
                Message={
                    'Body': {
                        'Html': {
                            'Charset': CHARSET,
                            'Data': EMAIL_BODY_HTML,
                        },
                        'Text': {
                            'Charset': CHARSET,
                            'Data': EMAIL_BODY_TXT,
                        },
                    },
                    'Subject': {
                        'Charset': CHARSET,
                        'Data': SUBJECT,
                    },
                },
                Source=SENDER,
            )
    # Display an error if something goes wrong.
    except ClientError as e:
        print(e.response['Error']['Message'])
    else:
        print("Email sent! Message ID:"),
        print(response['MessageId'])

# Format the actual email message from the values in
# the event message
# Format for both TXT and HTML emails
def format_email(message):

    # Grab some specifics before we loop through the message so we can format the beginning part of the email.
    # The reason for not looping through the entire event message is because it is easier to create
    # the top part of the email manually and then just loop through the message details later since we separate them out.
    alarmName = message["AlarmName"]
    newStateReason = message["NewStateReason"]
    awsAccountId = message["AWSAccountId"]
    region = message["Region"]

    #get the timestamp of the alarm/event
    stateChangeTime = message["StateChangeTime"]
    dt = dateutil.parser.parse(stateChangeTime)
    timestamp = unix_time_millis(dt)

     # Create the subject of the email
    SUBJECT = "ALARM: {0} in {1}".format(alarmName, region)

    # Creating the basic header of the email for TXT
    EMAIL_BODY_TXT = """
        You are receiving this email because your Amazon CloudWatch Alarm \"{0}\" in the \"{1}\" region has entered the ALARM state, because \"{2}\" at \"{3}\".\n

        View this alarm in the AWS Management Console:\n
        https://console.aws.amazon.com/cloudwatch/home?region=us-west-2#s=Alarms&alarm={0}\n

        Alarm Details:\n
        """.format(alarmName, region, newStateReason, timestamp )

    # Creating the basic header of the email for HTML emails
    EMAIL_BODY_HTML = """<html>
        <head></head>
        <body>
        <p>You are receiving this email because your Amazon CloudWatch Alarm \"{0}\" in the \"{1}\" region has entered the ALARM state, because \"{2}\" at \"{3}\"<p/>

        <p>View this alarm in the AWS Management Console:</p>
        <p>https://console.aws.amazon.com/cloudwatch/home?region=us-west-2#s=Alarms&alarm={0}</p>

        <p>Alarm Details:<br />
        """.format(alarmName, region, newStateReason, timestamp )

    # Separating out the Metrics section this will be found in the message["Trigger"]
    METRIC_DETAILS_TXT = "\nMonitored Metric:\n"
    METRIC_DETAILS_HTML = "<p>Monitored Metric:</p>"

    # loop through the event message and create the email with the desired information
    # Separate out the 'metric' section which is defined by 'trigger'

    for key,val in message.items():
        if "Trigger" in key:
            trigger = message["Trigger"]
            break
        EMAIL_BODY_TXT += "\t{} = {}\n".format(key, val)
        EMAIL_BODY_HTML += "<table><tr><td>{}:</td><td>{}</td></tr></table>".format(key, val)

    for tkey, tval in trigger.items():
        METRIC_DETAILS_TXT += "\t{} = {}\n".format(tkey, tval)
        METRIC_DETAILS_HTML += "<table><tr><td>{}:</td><td>{}</td></tr></table>".format(tkey, tval)

    # Now lets put the two sections together for both TXT and HTML emails.
    EMAIL_BODY_TXT += METRIC_DETAILS_TXT
    EMAIL_BODY_HTML += METRIC_DETAILS_HTML

    send_email(EMAIL_BODY_HTML, EMAIL_BODY_TXT,SUBJECT)

# simple function to just pull the 'message' from the event.  we can expand on this if needed
def get_event_message(event):
    messageText = event["Sns"]["Message"]
    message = json.loads(messageText)
    format_email(message)

# The SNS will send an 'event' with a message attached.
# Grab the event and see if it has the 'Records' in it, and if so send it off to be processed
# If not, send an email that we have no events recorded.  Doubtful, but just a troubleshooting part.
def lambda_handler(event, context):
    if "Records" in event:
        event = event["Records"][0]
        get_event_message(event)
    else:
        EMAIL_BODY_HTML = "NO VALID EVENT FOUND"
        EMAIL_BODY_TXT = "NO VALUD EVENT FOUND"
        SUBJECT = "SNS Alert with no event"
        send_email(EMAIL_BODY_HTML, EMAIL_BODY_TXT,SUBJECT)
