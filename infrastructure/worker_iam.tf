resource "aws_iam_role" "worker" {
  name = "eks-${var.name}-worker"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "worker_role_basic" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "worker_role_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "worker_role_ec2" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "worker_role_ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.worker.name
}

resource "aws_iam_policy" "worker_ebs_for_pv" {
  name        = "${var.name}-ebs-csi-uriver"
  path        = "/"
  description = "Allows worker nodes to attach Amazon EBS/NFS etc."
  policy      = file("${path.module}/policies/Amazon_EBS_CSI_Driver.json")
}

resource "aws_iam_role_policy_attachment" "worker_ebs_for_pv" {
  policy_arn = aws_iam_policy.worker_ebs_for_pv.arn
  role       = aws_iam_role.worker.name
}

# creates an instance profile for the above role
resource "aws_iam_instance_profile" "worker" {
  name = "eks-${var.name}-worker"
  role = aws_iam_role.worker.name
}

resource "aws_iam_role" "fargate" {
  name = "eks-${var.name}-fargate"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks_fargate_execution" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate.name
}

resource "aws_iam_role_policy_attachment" "fargate_role_basic" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.fargate.name
}

resource "aws_iam_role_policy_attachment" "fargate_role_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.fargate.name
}

resource "aws_iam_role_policy_attachment" "fargate_role_ec2" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.fargate.name
}

