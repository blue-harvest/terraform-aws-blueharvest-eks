resource "aws_security_group" "blueharvest-terraform-eks-openvpn" {
  name   = "${var.cluster_name}-openvpn"
  vpc_id = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 943
    to_port     = 943
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "blueharvest-terraform-eks-openvpn" {
  instance_type = "t3.medium"
  ami           = "${data.aws_ami.ubuntu.id}"

  vpc_security_group_ids = [
    "${aws_security_group.blueharvest-terraform-eks-openvpn.id}",
  ]

  availability_zone = "${var.availability_zones[0]}"
  subnet_id         = "${module.vpc.public_subnets[0]}"
  key_name          = "${aws_key_pair.blueharvest-terraform-eks.key_name}"

  tags = {
    Name        = "${var.cluster_name}-openvpn"
  }

  provisioner "file" {
    source      = "${path.module}/openvpn"
    destination = "~/scripts"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${tls_private_key.blueharvest-terraform-eks.private_key_pem}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod  -R +x ~/scripts",
      "ls -la ~/scripts",
      "~/scripts/install.sh",
      "make-cadir ~/openvpn",
      "cp ~/scripts/setup.sh ~/openvpn",
      "cp ~/scripts/interfaces.sh ~/openvpn",
      "cp ~/scripts/build-client-key.sh ~/openvpn",
      "cp ~/scripts/build-server-key.sh ~/openvpn",
      "cp ~/scripts/revoke.sh ~/openvpn",
      "cd ~/openvpn",
      "./setup.sh ${aws_instance.blueharvest-terraform-eks-openvpn.public_ip} ${var.cluster_name}",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${tls_private_key.blueharvest-terraform-eks.private_key_pem}"
    }
  }

  provisioner "local-exec" {
    command = "sftp -oStrictHostKeyChecking=no -i ${var.cluster_name}_key ubuntu@${aws_instance.blueharvest-terraform-eks-openvpn.public_ip}:client-configs/files/${var.cluster_name}.ovpn ./"
  }
}
