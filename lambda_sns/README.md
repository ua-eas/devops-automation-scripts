# AWS Lambda SNS 
   Trigger an alert when there at least one unhealthy KFS EC2 instance

## Cloudformation
 * Built using the kfs-resources.yaml cloudformation template.
 * IMPORTANT: To redeploy this template, it requires PRD to be destroyed and rebuilt.
 * Can also just use 'update stack' for minor changes like adding an email address.
 	- Update stack does not require a destroy/rebuild of PRD.

## Cloudwatch Alarm
Alarm info:
* Threshold: The condition in which the alarm will go to the ALARM state = UnHealthyHostCount > 0 for 10 datapoints within 10 minutes
* Actions: Send message to topic "kfs-prd-topic-lb" or "rice-prd-topic-lb"

This CloudWatch alarm monitors the ELB for PRD and will send an alert to the KFS or RICE SNS topics if the threshold is passed.

## SNS (AWS Simple Notification Service)
* Contains two topics
	- kfs-prd-topic-lb
	- rice-prd-topic-lb
* Both topics are suscribed to by the AWS Lambda function


The SNS service just accepts the CloudWatch alarm event, and passes it off to the subscription, which in this case is the Lambda function.

## AWS Lambda Function
kfs-resources-SNSLambdaFunction-(some random number AWS puts here)
* SNS Trigger
* Sends email using AWS SES (Simple Email Service)

This AWS Lambda function will accept the SNS event, parse the event message, and format it for both HTML and Text emails.  It will then send an email to 
the following email addresses listed in the function:
RECIPIENT = ["katt-automation-toolsadm@list.arizona.edu", "ua_met_app@tbginc.com"]

 * This email array can be updated manually by MET if there is an urgent need for someone else to get these emails.  
 * In any non emergency update, it should go through normal DevOps code release process.


