 #Adding security group
resource "aws_security_group" "allow_tls" {
  name_prefix   = "allow_tls"
  description   = "Allow TLS inbound traffic"
  vpc_id        = module.vpc.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  egress {
    description = "Allows outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}