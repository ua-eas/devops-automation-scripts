#!/bin/bash

##########################
# Purpose: Delete Route53 A records leftover 
# because Cloudformation will not delete them
# because undeploy does not work
###########################

# to allow nocase matching for jenkins
shopt -s nocasematch

export AWS_DEFAULT_REGION=us-west-2
set +x

# function to hold the JSON needed for the change-resource-record-sets
jsonDump() {

cat <<EOF
{
    "Comment": "Delete single record set",
    "Changes": [
        {
            "Action": "DELETE",
            "ResourceRecordSet": {                
                "Name": "$1",
                "Type": "A",
                "TTL": 900,
                "ResourceRecords": [
                    {
                        "Value": "$2"
                    }
                ]                
            }
        }
    ]
}
EOF

}

# NOTE: ENV_SLUG is passed in from the previous jobs and used in the route53 command below
ROUTE53_INFO=`aws route53 --region us-west-2 list-resource-record-sets --hosted-zone-id  ZP57AJPWE08JI --query "ResourceRecordSets[?contains(Name, '$ENV_SLUG') && Type == 'A']" --output=text`

# the list-resource-record-sets returns more than we need, so remove RESOURCERECORDS 900 and 'A' and keep only the DNS name and IP
ROUTE53_INFO=$(sed -e 's/RESOURCERECORDS//g' -e 's/900//g' -e 's/A//g' <<< $ROUTE53_INFO)

echo $ROUTE53_INFO

# loop through each line in ROUTE53_INFO.
# Grab the Name and the IP right after it correlates to that NAME
# then pass it to the function to delete the record set 
for item in $ROUTE53_INFO;
do  
       if [[ "$item" == kfs* ]] || [[ "$item" == rice* ]];
        then            
            NAME="$item"
            
        elif [[ "$item" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]];
            then
                ADDY="$item"                        

        printf "\n ***** call function with $NAME $ADDY *****\n"
        aws route53 change-resource-record-sets --hosted-zone-id ZP57AJPWE08JI --change-batch "$(jsonDump $NAME $ADDY)"
        fi
done




