locals {
  envs = ["dev-kpt", "prod-kpt", "dev-argo", "prod-argo", "dev-flux", "prod-flux"]
}

data "external" "thumbprint" {
  program = ["${path.module}/thumbprint.sh", data.aws_region.current.name]
}

resource "aws_iam_openid_connect_provider" "eks" {
  url = aws_eks_cluster.eks.identity.0.oidc.0.issuer

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [data.external.thumbprint.result.thumbprint]
}

resource "aws_iam_role" "external_dns_siam" {
  for_each = toset(local.envs)
  name = "eks-${var.name}-${each.value}-external-dns"

  assume_role_policy = templatefile("${path.module}/policies/oidc-eks.json", {
        provider = replace(aws_eks_cluster.eks.identity.0.oidc.0.issuer, "https://", ""),
        namespace = each.value,
        serviceaccount = "external-dns",
        account = local.account_id
    }
  )
  tags = var.tags
}

resource "aws_iam_policy" "external_dns" {
  for_each = toset(local.envs)

  name        = "${var.name}-${each.value}-ext-dns"
  path        = "/"
  description = "Allows pod to edit dns"
  policy      = templatefile("${path.module}/policies/external-dns.json", {
    zone = "Z023449622XOQW27RAVPQ"
  })
}

resource "aws_iam_role_policy_attachment" "external_dns" {
  for_each = toset(local.envs)

  policy_arn = aws_iam_policy.external_dns[each.value].arn
  role       = aws_iam_role.external_dns_siam[each.value].name
}

resource "aws_iam_role" "cert_manager_siam" {
  name = "eks-${var.name}-cert-manager"

  assume_role_policy = templatefile("${path.module}/policies/oidc-eks.json", 
    {
        provider = replace(aws_eks_cluster.eks.identity.0.oidc.0.issuer, "https://", ""),
        namespace = "cert-manager",
        serviceaccount = "cert-manager",
        account = local.account_id
    }
  )
  tags = var.tags
}

resource "aws_iam_policy" "cert_manager" {
  name        = "eks-${var.name}-cert-manager"
  path        = "/"
  description = "Allow K8s to manage records sets for use with cert-manager"
  policy      = file("${path.module}/policies/cert-manager.json")
}

resource "aws_iam_role_policy_attachment" "cert_manager" {
  policy_arn = aws_iam_policy.cert_manager.arn
  role       = aws_iam_role.cert_manager_siam.name
}

resource "aws_iam_role" "ingress_siam" {
  name = "eks-${var.name}-ingress"

  assume_role_policy = templatefile("${path.module}/policies/oidc-eks.json", {
        provider = replace(aws_eks_cluster.eks.identity.0.oidc.0.issuer, "https://", ""),
        namespace = "kube-system",
        serviceaccount = "aws-load-balancer-controller",
        account = local.account_id
    }
  )
  tags = var.tags
}

resource "aws_iam_policy" "ingress" {
  name        = "${var.name}-ingress"
  path        = "/"
  description = "Allows pod to edit dns"
  policy      = file("${path.module}/policies/aws-ingress.json")
}

resource "aws_iam_role_policy_attachment" "ingress" {
  policy_arn = aws_iam_policy.ingress.arn
  role       = aws_iam_role.ingress_siam.name
}
