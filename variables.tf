variable "region" {
  default = "eu-west-1"
}

variable "availability_zones" {
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "environment" {
  default = "dev"
}

variable "eks_ami_id" {
  default = "ami-01e08d22b9439c15a" //amazon-eks-node-1.11-v20190109
}

variable "instance_type" {
  default = "t2.large"
}

variable "asg_min_size" {
  default = "5"
}

variable "asg_max_size" {
  default = "24"
}

// Name of the EKS Cluster
variable "cluster_name" {
  default = "blueharvest"
}

// Root domain name of the hosted zone on AWS
variable "cluster_zone" {
  default = "blueharvest.io"
}

// ID of the hosted zone on AWS
variable "cluster_zone_id" {
  default = "Z31OVNF5EA1VAW"
}

// AWS Users to map to the EKS aws-auth configmap

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type        = "list"

  default = []
}

variable "map_users_count" {
  description = "The count of users in the map_users list."
  type        = "string"
  default     = 0
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type        = "list"
  default = []
}

variable "map_roles_count" {
  description = "The count of roles in the map_users list."
  type        = "string"
  default     = 0
}


// B64 encoded keys to be used
variable "cluster_private_key" {}

variable "cluster_public_key" {}