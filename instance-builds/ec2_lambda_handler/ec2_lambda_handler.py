import boto3
import os

region = os.environ.get('AWS_REGION')

ec2 = boto3.client('ec2', region_name=region)
response = ec2.describe_instances(Filters=[
        {
            'Name': 'tag:Auto-Start',
            'Values': [
                'true',
            ]
        },
    ])

instances = []

for reservation in response["Reservations"]:
    for instance in reservation["Instances"]:
        instances.append(instance["InstanceId"])

def stop(event, context):
    if instances:
        ec2.stop_instances(InstanceIds=instances)
        print('Stopped instances: ' + str(instances))
    else: 
        print('No Instances with Auto-Start tag.')
        
def start(event, context):
    if instances:
        ec2.start_instances(InstanceIds=instances)
        print('Started instances: ' + str(instances))
    else: 
        print('No Instances with Auto-Start tag.')
