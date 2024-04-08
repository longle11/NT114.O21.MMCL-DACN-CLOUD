# AWS Availability Zones Datasource  
data "aws_availability_zones" "available" {
    filter {
        name   = "opt-in-status"
        values = ["opt-in-not-required"]
    }
}

// lấy ra phiên bản ami mới nhất
data "aws_ami" "amzlinux2" {
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }
}