module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.cluster_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = "${var.availability_zones}"
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway  = true
  enable_vpn_gateway  = false
  enable_dhcp_options = false

  tags = {
    Name        = "${var.cluster_name}-vpc"
    Environment = "${var.environment}"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}
