
resource "aws_lb_target_group" "tg-loadbalancer" {
  name = "loadbalancer"
  vpc_id   = var.vpc_id
  port = 80
  protocol = "HTTP"
}

resource "aws_lb" "lb" {
  name               = "lb"
  load_balancer_type = "application"
  security_groups    = [var.aws_security_group_id]
  subnets            = var.aws_target_subnets_ids

  tags = {
    Environment = "dev"
  }
}

# resource "aws_lb_target_group_attachment" "a" {
#   target_group_arn = aws_lb_target_group.tg-loadbalancer.arn
#   target_id        = var.aws_target_id_2
# }

# resource "aws_lb_target_group_attachment" "b" {
#   target_group_arn = aws_lb_target_group.tg-loadbalancer.arn
#   target_id        = var.aws_target_id_1
# }

resource "aws_autoscaling_attachment" "asg_attachment_lb" {
  autoscaling_group_name = var.autoscaling_group_id
  alb_target_group_arn  = aws_lb_target_group.tg-loadbalancer.arn
}

resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-loadbalancer.arn
  }
}