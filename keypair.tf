resource "tls_private_key" "tls" {
  algorithm = "RSA"
  rsa_bits  = var.rsa_bits
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.aws_key_pair
  public_key = tls_private_key.tls.public_key_openssh
}