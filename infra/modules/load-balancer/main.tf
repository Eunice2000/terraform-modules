# Declaration of aws listener provisioning 
resource "aws_lb" "terraform-lb-1" {
  name               = "terraform-lb"
  ip_address_type    = "ipv4"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_groups]
  subnets            = var.subnets
}


# Declaration of aws load balancer listener provisioning 
resource "aws_lb_listener" "terraform-lb" {
  load_balancer_arn = aws_lb.terraform-lb-1.arn
  port              = 80
  protocol          = var.protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.terraform-tg-1.arn
  }
}


# Declaration of aws load balancer target group provisioning
resource "aws_lb_target_group" "terraform-tg-1" {
  name        = "terraform-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.aws-vpc-id

  health_check {
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    enabled             = true
  }
}


# Renders the below output after provisioning
output "aws-lb-target-group-arn" {
  value = aws_lb_target_group.terraform-tg-1.arn
}

output "aws-lb-subnet" {
  value = aws_lb.terraform-lb-1.subnets
}