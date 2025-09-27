########################################
# Load Balancer
########################################
resource "aws_lb" "app_alb" {
  name               = "app-alb"
  internal           = false # internet facing, gets public IP
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_main.id, aws_subnet.public_second.id]   # must be 2+ AZs

  enable_deletion_protection = false # can delete from console
  idle_timeout               = 60 # TCP keepalive time in the absence of traffic
  tags = { Name = "app-alb" }
}

########################################
# Target Group (HTTP → port 80)
########################################
resource "aws_lb_target_group" "tg" {
  name        = "app-tg"
  vpc_id      = aws_vpc.main.id
  protocol    = "HTTP"
  port        = 80
  target_type = "instance"

  health_check {
    protocol = "HTTP"
    path     = "/"
    port     = "80"
    matcher  = "200-399"
    interval = 30
  }
}

# Register the EC2 instance as a target
resource "aws_lb_target_group_attachment" "attach" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.main.id
  port             = 80
}

########################################
# Listener (HTTP 80 → forward to TG)
########################################
resource "aws_lb_listener" "http_80" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}