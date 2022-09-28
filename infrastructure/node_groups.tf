resource "aws_eks_node_group" "ec2" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "ec2-instances"
  instance_types  = ["t3a.large"]
  node_role_arn   = aws_iam_role.worker.arn
  subnet_ids      = local.private_subnets.*.id
  dynamic "remote_access" {
    for_each = var.key_name == null ? [] : [var.key_name] 
    content {
      ec2_ssh_key               = var.key_name
      source_security_group_ids = var.worker_remote_access_sgs
    }
  }

  scaling_config {
    desired_size = var.ec2_node_group_config.desired_size
    max_size     = var.ec2_node_group_config.max_size
    min_size     = var.ec2_node_group_config.min_size
  }

  depends_on = [
    aws_iam_role_policy_attachment.worker_role_basic,
    aws_iam_role_policy_attachment.worker_role_cni,
    aws_iam_role_policy_attachment.worker_role_ec2,
  ]
  tags = merge(var.tags, {Name = "eks-${var.name}-worker"})
}

# resource "aws_eks_node_group" "ec2_group_2" {
#   cluster_name    = aws_eks_cluster.eks.name
#   node_group_name = "ec2-instances-group-2"
#   instance_types  = ["t3a.large"]
#   node_role_arn   = aws_iam_role.worker.arn
#   subnet_ids      = local.private_subnets.*.id
#   dynamic "remote_access" {
#     for_each = var.key_name == null ? [] : [var.key_name] 
#     content {
#       ec2_ssh_key               = var.key_name
#       source_security_group_ids = var.worker_remote_access_sgs
#     }
#   }
#
#   scaling_config {
#     desired_size = var.ec2_node_group_config.desired_size
#     max_size     = var.ec2_node_group_config.max_size
#     min_size     = var.ec2_node_group_config.min_size
#   }
#
#   depends_on = [
#     aws_iam_role_policy_attachment.worker_role_basic,
#     aws_iam_role_policy_attachment.worker_role_cni,
#     aws_iam_role_policy_attachment.worker_role_ec2,
#   ]
#   tags = merge(var.tags, {Name = "eks-${var.name}-worker"})
# }
#
