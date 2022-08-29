terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
}

# Define sec group for the EC2 instance
resource "aws_security_group" "aws-striim-sg" {
  name        = "striim-security-groupo"
  description = "Allow incoming connections"
  vpc_id      =  var.vpc_id 
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming HTTP connections"
  }
 ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming SSH connections (Linux)"
  }
 ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Open port for Striim and databases"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }  
 }

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["self"]  
  filter {
    name   = "name"
    values = ["aws-centos-striim-image*"]
  }
}

# Create EC2 Instance with the custom image
resource "aws_instance" "aws-ec2-server" {
  ami                    = data.aws_ami.amazon-linux-2.id
  instance_type          = var.vm_instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.aws-striim-sg.id]
  source_dest_check      = false
  key_name               = var.key_name
  associate_public_ip_address = var.vm_associate_public_ip_address
  
  # root disk
  root_block_device {
    volume_size           = var.vm_root_volume_size
    volume_type           = var.vm_root_volume_type
    delete_on_termination = true
    encrypted             = true
  }
  # extra disk
  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = var.vm_data_volume_size
    volume_type           = var.vm_data_volume_type
    encrypted             = true
    delete_on_termination = true
  }
  
  tags = {
    Name = "striim-server"
  }
}

resource "aws_iam_policy" "stop_start_ec2_policy" {
  name = "StopStartEC2Policy"
  path = "/"
  description = "IAM policy for stop and start EC2 from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Start*",
        "ec2:Stop*",
        "ec2:DescribeInstances*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "stop_start_ec2_role" {
  name = "StopStartEC2Role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_role_policy" {
  role = "${aws_iam_role.stop_start_ec2_role.name}"
  policy_arn = "${aws_iam_policy.stop_start_ec2_policy.arn}"
}

data "archive_file" "lambda_zip" {
    type        = "zip"
    source_dir  = "${path.module}/ec2-lambda-handler"
    output_path = "${path.module}/ec2-lambda-handler.zip"
}

resource "aws_lambda_function" "stop_ec2_lambda" {
  filename      = "ec2_lambda_handler.zip"
  function_name = "stopEC2Lambda"
  role          = "${aws_iam_role.stop_start_ec2_role.arn}"
  handler       = "ec2_lambda_handler.stop"

  source_code_hash = "${data.archive_file.lambda_zip.output_base64sha256}"

  runtime = "python3.7"
  memory_size = "250"
  timeout = "60"
}

resource "aws_cloudwatch_event_rule" "ec2_stop_rule" {
  name        = "StopEC2Instances"
  description = "Stop EC2 nodes at 19:00 from Monday to friday"
  schedule_expression = "cron(0 19 ? * 2-6 *)"
}

resource "aws_cloudwatch_event_target" "ec2_stop_rule_target" {
  rule      = "${aws_cloudwatch_event_rule.ec2_stop_rule.name}"
  arn       = "${aws_lambda_function.stop_ec2_lambda.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_stop" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.stop_ec2_lambda.function_name}"
  principal     = "events.amazonaws.com"
}

resource "aws_lambda_function" "start_ec2_lambda" {
  filename      = "ec2_lambda_handler.zip"
  function_name = "startEC2Lambda"
  role          = "${aws_iam_role.stop_start_ec2_role.arn}"
  handler       = "ec2_lambda_handler.start"

  source_code_hash = "${data.archive_file.lambda_zip.output_base64sha256}"

  runtime = "python3.7"
  memory_size = "250"
  timeout = "60"
}

resource "aws_cloudwatch_event_rule" "ec2_start_rule" {
  name        = "StartEC2Instances"
  description = "Start EC2 nodes at 6:30 from Monday to friday"
  schedule_expression = "cron(30 6 ? * 2-6 *)"
}

resource "aws_cloudwatch_event_target" "ec2_start_rule_target" {
  rule      = "${aws_cloudwatch_event_rule.ec2_start_rule.name}"
  arn       = "${aws_lambda_function.start_ec2_lambda.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_start" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.start_ec2_lambda.function_name}"
  principal     = "events.amazonaws.com"
}
