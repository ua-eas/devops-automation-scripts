#!/usr/bin/python3

import json
import boto3
import os
import sys
import re

""" 
Purpose: Restart docker containers in a prototype
Logic:
    1. Get an opsworks 'stack name' and 'app to bounce' from the user
    2. Using that stack name, get a stack Id number for that opsworks stack
    3. Using that stack ID, get EC2 instance IDs because AWS CLI does not allow us to use stack-name
    4. Restart requested docker containers
"""

# set up the opsworks client so we can get the opsworks info we need
opsworks_client = boto3.client('opsworks', region_name="us-east-1")

# set up the SSM (AWS Systems Manager).  This allows us to run commands on EC2 instances
ssm = boto3.client('ssm', region_name="us-west-2")    


# this is how we get a jenkins param in python
stackName = sys.argv[1].lower().strip()  # used for local testing
# stackName = os.environ['STACK_NAME'].lower().strip() # for jenkins

# same thing for which app to restart kfs/rice/both
# app_to_bounce = os.environ['RESTART_WHAT_INSTANCE']  # for jenkins
app_to_bounce = "KFS"


print(len(stackName))
if len(stackName) < 9:
    print("Please make sure you have a full prototype name")
    exit()

print(f"==== App(s) to bounce will be: {app_to_bounce} ======")


"""
   do not allow dev/tst/stg/trn to be restarted at this time
"""
def checkStackName(stackName):
    
    if stackName == "stg" or stackName == "dev" or stackName == "tst" or stackName == "trn":
        print("Only prototypes are allowed to be bounced using this job")
        exit()   

"""
  Takes an opsworks stack name and returns the stack ID number  
  This will be used to get the instance IDs
"""
def getStackId(stackName):            

    stacks = opsworks_client.describe_stacks( 
        # pass no paramaters so we return all stacks
    )    
    
    print(f"\n==== Stack name passed in = {stackName} ====\n")

    # loop through the dictionary and search for the stack name
    # inherent flaw.  If you enter dev1 it will return something because of dev151 or dev171
    # TODO:  Fix so it searches on exact match
    try:
        for key, val in stacks.items():            
            for stackItem in val:
                # there are some odd str values returned that are outside of the normal JSON.this ignores them as they are not needed.                
                if isinstance(stackItem, str):
                    continue
                                
                if stackName in stackItem["Name"]:      
                    stackId = stackItem["StackId"]
                    break
      
        return(stackId)
    except:
        print("No stack ID found for that stack name.  Either the name is wrong, or the instances are turned off")
        exit()
    
"""
    Get and return all the instance IDs associated with this stack
    These will be used to restart the docker container later
"""    
def getstackInstanceIds(stackId, stackName, app_to_bounce):    
    opsworks_instances = opsworks_client.describe_instances(
        StackId=stackId
        )    

    # Create a list to return instance ids for a specific app KFS or RICE
    ec2InstanceIds = []  

    # Create a dict to hold key/value pairs if they want to restart ALL.  Need this because of the docker commands needing to know kfs vs rice.
    all_instance_ids = {}

    for key, val in opsworks_instances.items():           
        for stackItem in val:
            if isinstance(stackItem, str):
                continue    

            if app_to_bounce == "KFS":
                if "kfs7-" in stackItem["Hostname"]:                                    
                    ec2InstanceIds.append(stackItem.get("Ec2InstanceId"))
                    all_instance_ids["KFS"] = stackItem["Ec2InstanceId"]
            elif app_to_bounce == "RICE":
                if "rice-" in stackItem["Hostname"]:                      
                    ec2InstanceIds.append(stackItem.get("Ec2InstanceId"))
                    all_instance_ids[stackItem["Hostname"]] = stackItem["Ec2InstanceId"]
            elif app_to_bounce == "BOTH":
                all_instance_ids[stackItem["Hostname"]] = stackItem["Ec2InstanceId"]            
    

    # if there are no values in the list ec2InstanceIds then that means the app to bounce = BOTH
    # so we want to return the dictionary with key/value pairs because we will need to separate out later
    # what docker restart to build based on kfs vs rice
    if not ec2InstanceIds:
        ec2InstanceIds = all_instance_ids
    
    return ec2InstanceIds

"""
 Bounce the EC2 instances
 We will use the aws cli SSM tool for this and 
 need the Instance IDs which were gathered before
"""
def bounceInstances(stackInstanceIds, app_to_bounce):
    print("\n===== Bouncing the Instances...boing boing boing =========")

    if app_to_bounce == "BOTH":
        for host_name, instance_id in stackInstanceIds.items():
            if "kfs7-" in host_name:
                docker_restart_command = "sudo docker restart kfs7"
            else:
                docker_restart_command = "sudo docker restart rice" 
            print(f"InstanceIds={instance_id},DocumentName='AWS-RunShellScript', Comment='Restart docker containers', Parameters= 'commands':[ {docker_restart_command} ]")             
            # SSMCommand = ssm.send_command( InstanceIds=[instance_id],DocumentName='AWS-RunShellScript', Comment='Restart docker containers', Parameters={ "commands":[ docker_restart_command ]  } )

    else:            
        for instance_id in stackInstanceIds:
            if app_to_bounce == "KFS":                
                docker_restart_command = "sudo docker restart kfs7"           
            elif app_to_bounce == "RICE":                
                docker_restart_command = "sudo docker restart rice"           
            else:           
                docker_restart_command = "sudo docker restart BOTH"

            print(f"InstanceIds={instance_id},DocumentName='AWS-RunShellScript', Comment='Restart docker containers', Parameters= 'commands':[ {docker_restart_command} ]")
            # SSMCommand = ssm.send_command( InstanceIds=[instance_id],DocumentName='AWS-RunShellScript', Comment='Restart docker containers', Parameters={ "commands":[ docker_restart_command ]  } )


# check the stack name is valid        
checkStackName(stackName)

# Get the Stack ID from the opsworks instance
opsworksStackId = getStackId(stackName)

# get all the instance ids
stackInstanceIds = getstackInstanceIds(opsworksStackId, stackName, app_to_bounce)

# now bounce the container(s)
bounceInstances(stackInstanceIds, app_to_bounce)







