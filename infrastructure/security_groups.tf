# Master
resource "aws_security_group" "master" {
  name        = "eks-${var.name}-master"
  description = "Cluster communication with worker nodes"
  vpc_id      = data.aws_vpc.vpc.id

  tags = merge(
    var.tags,
    {
      "Name" = "eks-${var.name}-master",
      "kubernetes.io/cluster/${var.name}" = "owned"
    }
  )
}

resource "aws_security_group_rule" "master_egress_all" {
  description              = "Allow all outbound traffic"
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  cidr_blocks              = ["0.0.0.0/0"]
  security_group_id        = aws_security_group.master.id
}

# resource "aws_security_group_rule" "master_sg_ingress_workstation_https" {
#   description       = "Allow workstation to communicate with the cluster API Server"
#   type              = "ingress"
#   from_port         = 443
#   to_port           = 443
#   protocol          = "tcp"
#   cidr_blocks       = var.master_eks_sg_inbound_local
#   security_group_id = aws_security_group.master.id
# }

resource "aws_security_group_rule" "master_sg_internal" {
  description              = "Allow internal communication within VPC"
  type                     = "ingress"
  to_port                  = 65535
  from_port                = 0
  protocol                 = "tcp"
  cidr_blocks              = [data.aws_vpc.vpc.cidr_block]
  security_group_id        = aws_security_group.master.id
}

