data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-20180306"]
  }
}

resource "aws_key_pair" "blueharvest-terraform-eks" {
  key_name   = "${var.cluster_name}"
  public_key = "${base64decode(var.cluster_public_key)}"
}
