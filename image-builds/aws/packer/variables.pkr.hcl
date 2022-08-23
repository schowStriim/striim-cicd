variable "region" {
  type    = string
  default = "us-west-2"
}

variable "instance_type" {
  type    = string
  default = "t2.xlarge"
}

variable "ami_name" {
  type    = string
  default = "dev-centos-striim"
}

variable "base_ami" {
  type    = string
  default = "ami-0cea098ed2ac54925"
}

variable "subnet_id" {
  type    = string
  default = "subnet-d1806f89"
}

variable "security_group_id" {
  type    = string
  default = "sg-25947c43"
}
