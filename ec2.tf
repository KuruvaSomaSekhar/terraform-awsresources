resource "aws_security_group" "httpd" {
  name        = "httpd"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.demo.id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    description = "SSH from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "httpd"
  }
}

resource "aws_instance" "demoAPP" {
  ami           = "ami-0e8a34246278c21e4"
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.public-sn-1a.id
  count         = 3

  key_name        = "terraform-kp"
  security_groups = [aws_security_group.httpd.id]
  user_data       = file("${path.module}/httpd.sh")

  tags = {
    Name = "demoAPP-${count.index + 1}"
  }
}