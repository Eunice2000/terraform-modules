# Declaration aws launch template provisioning 
resource "aws_launch_template" "nginx-lt" {
  name                   = "nginx-lt"
  image_id               = var.aws-ami-id
  instance_type          = "t2.micro"
  key_name               = "terraformkey"
  vpc_security_group_ids = [var.aws-security-group-id]
  user_data              = var.file-path

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name : "nginx-lt"
    }
  }
}


# Declaration of aws autoscaling group provisioning
resource "aws_autoscaling_group" "terraform-asg" {
  name                      = "terraform-asg"
  vpc_zone_identifier       = var.aws-lb-subnet
  max_size                  = 10
  min_size                  = 2
  desired_capacity          = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  target_group_arns         = [var.aws-lb-target-group-arn]

  launch_template {
    id      = aws_launch_template.nginx-lt.id
    version = "$Latest"
  }
}
