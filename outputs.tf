output "alb-dns-name" {
  value       = aws_lb.demoALB.dns_name
}

output "elb-dns-name" {
    value = aws_elb.myelb[0].dns_name
}