# terraform-aws-blueharvest-eks

Terraform module that provisions an EKS cluster including a VPC, a VPN, Helm, Kubernetes Dashboard, NGINX Ingress, Cert Manager, External DNS, ELK, Prometheus, Grafana and Istio.

## Assumptions

* You have [`kubectl`](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl) (>=1.11) on your shell's PATH.
* You have [`helm`](https://github.com/helm/helm/blob/master/docs/install.md) (>=2.12.1) on your shell's PATH.
* You have [`aws-iam-authenticator`](https://github.com/kubernetes-sigs/aws-iam-authenticator#4-set-up-kubectl-to-use-authentication-tokens-provided-by-aws-iam-authenticator-for-kubernetes) on your shell's PATH.

## Usage example

A full example leveraging other community modules is contained in the [examples directory](https://github.com/blue-harvest/terraform-aws-blueharvest-eks/tree/master/examples). Here's the gist of using it via the Terraform registry:

```hcl
module "blueharvest-eks" {
  source              = "terraform-aws-blueharvest-eks"
  region              = "eu-west-1"
  availability_zones  = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  eks_ami_id          = "ami-01e08d22b9439c15a" //amazon-eks-node-1.11-v20190109
  instance_type       = "t2.large"
  asg_min_size        = "5"
  asg_max_size        = "20"
  cluster_name        = "testcluster"
  cluster_zone        = "mycompany.io"
  cluster_zone_id     = "Z31OWNFWWA1VAW"
  map_users           = [] # List of AWS users (arn) to map to K8S users
  map_roles           = [] # List of AWS roles (arn) to map to K8S roles
  map_users_count     = 0
  map_roles_count     = 0
}
```

Before running the module, you must define the following environment variables:

```bash
export AWS_DEFAULT_REGION="..."
export AWS_ACCESS_KEY_ID="....."
export AWS_SECRET_ACCESS_KEY="....."
export TF_VAR_cluster_private_key=$CLUSTER_PRIVATE_KEY #B64 encoded private key
export TF_VAR_cluster_public_key=$CLUSTER_PUBLIC_KEY   #B64 encoded public key
```

## IAM Permissions

The following IAM policy is the minimum needed to execute the module from the test suite.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": [
        "autoscaling:AttachInstances",
        "autoscaling:CreateAutoScalingGroup",
        "autoscaling:CreateLaunchConfiguration",
        "autoscaling:CreateOrUpdateTags",
        "autoscaling:DeleteAutoScalingGroup",
        "autoscaling:DeleteLaunchConfiguration",
        "autoscaling:DeleteTags",
        "autoscaling:Describe*",
        "autoscaling:DetachInstances",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:UpdateAutoScalingGroup",
        "ec2:AllocateAddress",
        "ec2:AssignPrivateIpAddresses",
        "ec2:Associate*",
        "ec2:AttachInternetGateway",
        "ec2:AttachNetworkInterface",
        "ec2:AuthorizeSecurityGroupEgress",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CreateDefaultSubnet",
        "ec2:CreateDhcpOptions",
        "ec2:CreateEgressOnlyInternetGateway",
        "ec2:CreateInternetGateway",
        "ec2:CreateNatGateway",
        "ec2:CreateNetworkInterface",
        "ec2:CreateRoute",
        "ec2:CreateRouteTable",
        "ec2:CreateSecurityGroup",
        "ec2:CreateSubnet",
        "ec2:CreateTags",
        "ec2:CreateVolume",
        "ec2:CreateVpc",
        "ec2:DeleteDhcpOptions",
        "ec2:DeleteEgressOnlyInternetGateway",
        "ec2:DeleteInternetGateway",
        "ec2:DeleteNatGateway",
        "ec2:DeleteNetworkInterface",
        "ec2:DeleteRoute",
        "ec2:DeleteRouteTable",
        "ec2:DeleteSecurityGroup",
        "ec2:DeleteSubnet",
        "ec2:DeleteTags",
        "ec2:DeleteVolume",
        "ec2:DeleteVpc",
        "ec2:DeleteVpnGateway",
        "ec2:Describe*",
        "ec2:DetachInternetGateway",
        "ec2:DetachNetworkInterface",
        "ec2:DetachVolume",
        "ec2:Disassociate*",
        "ec2:ModifySubnetAttribute",
        "ec2:ModifyVpcAttribute",
        "ec2:ModifyVpcEndpoint",
        "ec2:ReleaseAddress",
        "ec2:RevokeSecurityGroupEgress",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:UpdateSecurityGroupRuleDescriptionsEgress",
        "ec2:UpdateSecurityGroupRuleDescriptionsIngress",
        "ec2:CreateLaunchTemplate",
        "ec2:CreateLaunchTemplateVersion",
        "ec2:DeleteLaunchTemplate",
        "ec2:DeleteLaunchTemplateVersions",
        "ec2:DescribeLaunchTemplates",
        "ec2:DescribeLaunchTemplateVersions",
        "ec2:GetLaunchTemplateData",
        "ec2:ModifyLaunchTemplate",
        "eks:CreateCluster",
        "eks:DeleteCluster",
        "eks:DescribeCluster",
        "eks:ListClusters",
        "iam:AddRoleToInstanceProfile",
        "iam:AttachRolePolicy",
        "iam:CreateInstanceProfile",
        "iam:CreatePolicy",
        "iam:CreatePolicyVersion",
        "iam:CreateRole",
        "iam:DeleteInstanceProfile",
        "iam:DeletePolicy",
        "iam:DeleteRole",
        "iam:DeleteRolePolicy",
        "iam:DeleteServiceLinkedRole",
        "iam:DetachRolePolicy",
        "iam:GetInstanceProfile",
        "iam:GetPolicy",
        "iam:GetPolicyVersion",
        "iam:GetRole",
        "iam:GetRolePolicy",
        "iam:List*",
        "iam:PassRole",
        "iam:PutRolePolicy",
        "iam:RemoveRoleFromInstanceProfile",
        "iam:UpdateAssumeRolePolicy"
      ],
      "Resource": "*"
    }
  ]
}
```

## License

MIT Licensed. See [LICENSE](https://github.com/blue-harvest/terraform-aws-blueharvest-eks/tree/master/LICENSE) for full details.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| cluster\_name | Name of the EKS cluster that will be used to prefix most of the created resources. | string | `"blueharvest"` | no |

## Outputs
| Name | Description |
|------|-------------|
| kubectl\_config | Kubectl configuration file. |