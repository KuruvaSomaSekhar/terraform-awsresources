resource "aws_lb" "demoALB" {
  name               = "demoALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.httpd.id]
  subnets            = [aws_subnet.public-sn-1b.id, aws_subnet.public-sn-1a.id]

  enable_deletion_protection = false


  tags = {
    Environment = "demoALB"
  }
}

resource "aws_lb_target_group" "tg" {
  name     = "demoTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.demo.id
}

resource "aws_lb_target_group_attachment" "test" {
  count = length(aws_instance.demoAPP)

  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.demoAPP[count.index].id
  port             = 80
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.demoALB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}