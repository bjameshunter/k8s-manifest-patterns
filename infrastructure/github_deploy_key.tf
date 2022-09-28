# Configure the GitHub Provider
provider "github" {
  # organization = var.github_organization
}

# # Add a deploy key
resource "github_repository_deploy_key" "fluxcd_deploy_key" {
  title      = "${var.name}-gitops"
  repository = local.repo_name
  key        = replace(local.pk == "" ? data.external.flux_public_key.result["key"] : local.pk, "/= .*/", "=")
  read_only  = "false"
  depends_on = [aws_eks_cluster.eks, data.external.flux_public_key]
  provisioner "local-exec" {
    command = "./${path.module}/scripts/flux-public-key.sh | jq -r '.key' > ${path.module}/scripts/flux-public-key.pem"
  }
}

data "external" "flux_public_key" {
  program = ["${path.module}/scripts/flux-public-key.sh"]
  depends_on = [aws_eks_cluster.eks]
}

locals {
  repo_name = replace(replace(var.gitops_repo, "git@github.com:bjameshunter/", ""), ".git", "")
  pk = file("${path.module}/scripts/flux-public-key.pem")
}
