data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-20180306"]
  }
}

provider "tls" {}

resource "tls_private_key" "blueharvest-terraform-eks" {
  algorithm = "RSA"
  rsa_bits  = "2048"

  provisioner "local-exec" {
    command     = "echo \"${tls_private_key.blueharvest-terraform-eks.private_key_pem}\" >> ./\"${var.cluster_name}\"_key"
    interpreter = ["/bin/sh", "-c"]
  }

  provisioner "local-exec" {
    command     = "echo \"${tls_private_key.blueharvest-terraform-eks.private_key_pem}\" >> ./\"${var.cluster_name}\"_key.pub"
    interpreter = ["/bin/sh", "-c"]
  }

  provisioner "local-exec" {
    command     = "chmod 600 \"${var.cluster_name}\"_key"
    interpreter = ["/bin/sh", "-c"]
  }
}

resource "aws_key_pair" "blueharvest-terraform-eks" {
  key_name   = "${var.cluster_name}"
  public_key = "${tls_private_key.blueharvest-terraform-eks.public_key_openssh}"
}
