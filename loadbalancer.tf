resource "aws_elb" "myelb" {
  name = "demoELB"
  security_groups = [aws_security_group.httpd.id]
  subnets         = [aws_subnet.public-sn-1b.id, aws_subnet.public-sn-1a.id]


  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }


  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/index.html"
    interval            = 30
  }
  count = length(aws_instance.demoAPP)
  #instances                   = [aws_instance.demoAPP[0].id, aws_instance.demoAPP[1].id, aws_instance.demoAPP[2].id]
  instances                   = [aws_instance.demoAPP[count.index].id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400


}