module "ec2_bastion_public" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.1"

  name = "${var.aws_environment}-bastion-public"

  ami = data.aws_ami.amzlinux2.id
  instance_type = var.aws_instance_type
  key_name = var.aws_key_pair

  subnet_id = module.vpc.public_subnets[0]
  vpc_security_group_ids = [module.ec2_bastion_sg.security_group_id]
}

//create elastic ip for bastion host
resource "aws_eip" "bastion_elastic_ip" {
  //Check dependencies if components have been created that elastic ip must be created
  depends_on = [ module.vpc, module.ec2_bastion_public.id ]

  //EC2 instance ID.
  instance = module.ec2_bastion_public.id
  //Check Elastic IP belongs to VPC
#   vpc = true
  tags = {
    Environment = var.aws_environment
  }
}

//create null resource and provisioners to copy key-pair and send to bastion host
resource "null_resource" "copy-private-key" {
  depends_on = [ module.ec2_bastion_public ]

  #Connection block for provisioners to connect to ec2 instance
  connection {
    host = aws_eip.bastion_elastic_ip.public_ip
    type = "ssh"
    user = "ec2-user"
    password = ""
    private_key = file("authentication_keypairs/${var.aws_key_pair}.pem")
  }

  //copy private key from folder authentication_keypairs to /tmp/keypair.pem
  provisioner "file" {
    source = "authentication_keypairs/${var.aws_key_pair}.pem"
    destination = "/tmp/${var.aws_key_pair}.pem"
  }
  #Using remote-exec provisioner fix the private key permissions on Bastion Host
  provisioner "remote-exec" {
    inline = [ "sudo chmod 400 /tmp/${var.aws_key_pair}.pem" ] 
  }

  #local-exec provisioner (Creation-Time Provisioner - Triggered during Create Resource)
  provisioner "local-exec" {
    command = "echo VPC created on `date` and VPC ID: ${module.vpc.vpc_id} >> creation-time-vpc-id.txt"
    working_dir = "exec-local-output-files/"
  }
}



