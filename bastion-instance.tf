resource "aws_instance" "blueharvest-terraform-eks-bastion" {
  key_name               = "${aws_key_pair.blueharvest-terraform-eks.key_name}"
  vpc_security_group_ids = ["${aws_security_group.blueharvest-terraform-eks-bastion.id}"]
  availability_zone      = "${var.availability_zones[0]}"
  subnet_id              = "${module.vpc.public_subnets[0]}"
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "t2.micro"

  tags {
    Name        = "${var.cluster_name}-bastion"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "blueharvest-terraform-eks-bastion" {
  vpc_id = "${module.vpc.vpc_id}"
  name   = "${var.cluster_name}-bastion"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "${var.cluster_name}-bastion"
    Environment = "${var.environment}"
  }
}
