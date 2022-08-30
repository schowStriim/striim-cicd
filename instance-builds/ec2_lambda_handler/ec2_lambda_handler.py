import boto3
import os

region = os.environ.get('AWS_REGION')

ec2 = boto3.client('ec2', region_name=region)
rds = boto3.client('rds')
rds_instances = []
ec2_instances = []

rds_response = rds.describe_db_instances()

def rds_stop_instance(response):
    
    # Locate all instances that are tagged ttl.
    for instance in rds_response["DBInstances"]:
        
        tags = rds.list_tags_for_resource(ResourceName=instance["DBInstanceArn"])
                
        for tag in tags["TagList"]:
            if tag['Key'] == 'Auto-Start':
                     if tag['Value'] == 'true':
                         rds.stop_db_instance(DBInstanceIdentifier=instance["DBInstanceIdentifier"])
                        print("Stopped RDS Instance: ", instance["DBInstanceIdentifier"])
                    
def rds_start_instance(response):
    
    # Locate all instances that are tagged ttl.
    for instance in rds_response["DBInstances"]:
        
        tags = rds.list_tags_for_resource(ResourceName=instance["DBInstanceArn"])
                
        for tag in tags["TagList"]:
            if tag['Key'] == 'Auto-Start':
                     if tag['Value'] == 'true':
                         rds.start_db_instance(DBInstanceIdentifier=instance["DBInstanceIdentifier"])
                         print("Started RDS Instance: ", instance["DBInstanceIdentifier"])
                         
response = ec2.describe_instances(Filters=[
        {
            'Name': 'tag:Auto-Start',
            'Values': [
                'true',
            ]
        },
    ])


for reservation in response["Reservations"]:
    for instance in reservation["Instances"]:
        ec2_instances.append(instance["InstanceId"])

def stop(event, context):
    if ec2_instances:
        ec2.stop_instances(InstanceIds=ec2_instances)
        rds_stop_instance(rds_response)
        print('Stopped EC2 instances: ' + str(ec2_instances))
    else: 
        print('No Instances with Auto-Start tag.')
        
def start(event, context):
    if ec2_instances:
        rds_start_instance(rds_response)
        ec2.start_instances(InstanceIds=ec2_instances)
        print('Started EC2 instances: ' + str(ec2_instances))
    else: 
        print('No Instances with Auto-Start tag.')

