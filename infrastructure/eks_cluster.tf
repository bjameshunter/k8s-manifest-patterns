data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
}

data "aws_subnet" "private" {
  for_each = toset(data.aws_subnets.private.ids)
  id       = each.value
}

locals {
  private_subnets = length(var.private_subnets) > 0 ? tolist(var.private_subnets) : [for k, v in data.aws_subnet.private: v]
}

resource "aws_eks_cluster" "eks" {
  name     = var.name
  version  = var.eks_version
  role_arn = aws_iam_role.master.arn
vpc_config {
    endpoint_public_access  = var.endpoint_public_access
    endpoint_private_access = var.endpoint_private_access

    security_group_ids = [aws_security_group.master.id]
    subnet_ids         = local.private_subnets.*.id
  }

  enabled_cluster_log_types = ["api","audit","authenticator","controllerManager","scheduler"]

  depends_on = [
    aws_iam_role_policy_attachment.master_role_basic,
    aws_iam_role_policy_attachment.master_role_service,
  ]

  tags = var.tags
}
 
resource "null_resource" "cluster" {
  triggers = {
    git_ops_trigger = "${var.name} ${var.gitops_repo} ${var.gitops_branch}"
  }

  provisioner "local-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    command = join(" ", [
        "./${path.module}/scripts/bootstrap-cluster.sh", 
        var.name,
        var.gitops_repo,
        var.gitops_branch
    ])
  }
  depends_on = [aws_eks_cluster.eks]
}

resource "null_resource" "subnets" {
  for_each = toset([for s in local.private_subnets: s.id])
  provisioner "local-exec" {
    command = join(" ", [
        "./${path.module}/scripts/subnets.sh", 
        each.value,
        var.name
    ])
  }
}

