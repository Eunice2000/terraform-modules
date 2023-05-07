# Declaration of configuration provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.0"
    }
  }
}


# Declaration of aws vpc availabilty zone
provider "aws" {
  region = "us-east-1"
}
#local storage

# Loads aws default vpc resource
module "aws_vpc" {
  source = "./modules/vpc"
}


# Loads aws default ami
module "aws_ami" {
  source = "./modules/ami"
}


# Renders script file for nginx configuration
data "template_file" "script-file" {
  template = "${file("./user-data.tpl")}"
}


# Loads aws security group for http&shh request resource
module "aws_security_group" {
  source = "./modules/security-group"
  http-port = 80
  ssh-port = 22
}


# Loads aws load balancer and listener and component declaration
module "load-balancer" {
  source = "./modules/load-balancer"
  security_groups = module.aws_security_group.security_groups_id
  subnets = module.aws_vpc.aws_subnets
  aws-vpc-id = module.aws_vpc.aws_default_vpc
  protocol = "HTTP"
}


# Loads aws autoscaling group launch template resource
module "aws_autoscaling_group" {
  source = "./modules/autoscaling"
  aws-ami-id = module.aws_ami.ami
  aws-security-group-id = module.aws_security_group.security_groups_id
  file-path = base64encode(data.template_file.script-file.rendered)
  aws-lb-subnet = module.load-balancer.aws-lb-subnet
  aws-lb-target-group-arn = module.load-balancer.aws-lb-target-group-arn
}
