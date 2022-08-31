# Instance Builds 

### The purpose of this `instance-builds` directory is to define a Striim server and the infrastructure to turn on/off EC2 and RDS instances using Terraform.

Deploys the following resources:
  1) S3 bucket to store Terraform's state file (Encrypted) and Dynamodb table tos tore Terraform lock id.
  2) Security group with Striim open ports (9080).
  3) EC2 instance with the attached security group and latest Striim image
  4) Intance Scheduler infrastructure:
     - 2 Lambdas (One to stop RDS/EC2 instances and the other one to start the instances)
     - 2 Eventbridge rules (Starts the EC2 and RDS instances at 8:00AM PST and turns it off at 8:00PM PST)
     - IAM roles with permission to invoke lambdas, describe EC2/RDS instances, start/stop instances and etc...
     



