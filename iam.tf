resource "aws_iam_role_policy_attachment" "workers_route53" {
  policy_arn = "${aws_iam_policy.worker_route53.arn}"
  role       = "${module.eks.worker_iam_role_name}"
}

resource "aws_iam_policy" "worker_route53" {
  name_prefix = "eks-worker-route53-${var.cluster_name}"
  description = "EKS worker node route53 policy for cluster ${var.cluster_name}"
  policy      = "${data.aws_iam_policy_document.worker_route53.json}"
}

data "aws_iam_policy_document" "worker_route53" {
  statement {
    sid    = "eksWorkerChangeResourceRecordSets"
    effect = "Allow"
    actions = ["route53:ListHostedZonesByName", "route53:ChangeResourceRecordSets"]
    resources = ["arn:aws:route53:::hostedzone/*"]
  }

  statement {
    sid       = "eksWorkerGetChange"
    effect    = "Allow"
    actions   = ["route53:GetChange"]
    resources = ["arn:aws:route53:::change/*"]
  }

  statement {
    sid       = "eksWorkerListHostedZones"
    effect    = "Allow"
    actions   = ["route53:ListHostedZones", "route53:ListResourceRecordSets"]
    resources = ["*"]
  }
}
