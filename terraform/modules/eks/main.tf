resource "aws_security_group" "cluster" {
  name        = "${var.name}-cluster-sg"
  description = "EKS cluster security group"
  vpc_id      = data.aws_subnet.selected.vpc_id
  tags        = merge(var.tags, { Name = "${var.name}-cluster-sg" })
}

data "aws_subnet" "selected" {
  id = var.subnet_ids[0]
}

resource "aws_eks_cluster" "this" {
  name     = var.name
  role_arn = var.role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
    security_group_ids      = [aws_security_group.cluster.id]
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "scheduler", "controllerManager"]

  tags = var.tags
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "coredns"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "kube-proxy"
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "vpc-cni"
}
