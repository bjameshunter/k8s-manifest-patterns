variable "name" {
  type        = string
  description = "EKS cluster name"
}

variable "vpc_name" {
  type        = string
  description = "AWS VPC name"
}

variable "tags" {
  type        = map
  description = "Common tags to be included in all taggable resources"
}

variable "private_subnets" {
  type        = list
  description = "List of subnet objects with 'id' attribute."
  default     = []
}

variable "ec2_node_group_config" {
  type        = map
  description = "map of desired EC2 config for EKS node_group"
  default     = {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }
}

variable "worker_remote_access_sgs" {
  type        = list
  description = "list of sgs to allow inbound traffic to workers"
  default     = []
}

variable "hosted_zone" {
  type        = string
  description = "Hosted Zone for external DNS."
}

variable "endpoint_public_access" {
  type = bool
  default = true
  description = "Should AWS EKS public API server endpoint be enabled"
}

variable "endpoint_private_access" {
  type = bool
  default = false
  description = "Should AWS EKS private API server endpoint be enabled"
}

variable "master_eks_sg_inbound_local"{
  type        = list
  description = "List of cidrs that should be able to use kubectl"
  default     = []
}

# EKS parameters
variable "eks_version" {
  type        = string
  description = "The version of EKS to target"
  default     = "1.21"
}

variable "key_name" {
  type        = string
  description = "SSH Key name for access to workers"
  default     = null
}

## Github

variable "github_organization" {
  type        = string
  description = "Github org"
  default     = null
}

variable "gitops_repo" {
  type        = string
  description = "SSH to git repo for FluxCD cluster management"
}

variable "gitops_branch" {
  type        = string
  description = "Git branch for GitOps repo"
  default     = "main"
}

