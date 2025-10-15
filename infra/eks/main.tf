module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  cluster_name         = var.cluster_name
}

module "iam" {
  source       = "./modules/iam"
  cluster_name = var.cluster_name
}

module "eks" {
  source            = "./modules/eks"
  cluster_name      = var.cluster_name
  cluster_version   = var.cluster_version
  subnet_ids        = module.vpc.private_subnet_ids
  vpc_id            = module.vpc.vpc_id
  cluster_role_arn  = module.iam.cluster_role_arn
}

resource "local_file" "aws_auth_cm" {
  filename = "${path.module}/aws-auth.yaml"
  content  = <<-YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${module.iam.node_instance_role_arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
YAML
}

resource "null_resource" "apply_aws_auth" {
  triggers = {
    cm_hash = sha1(local_file.aws_auth_cm.content)
  }

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.region} && kubectl apply -f ${local_file.aws_auth_cm.filename}"
  }

  depends_on = [module.eks]
}

module "self_nodegroup" {
  source                      = "./modules/self_nodegroup"
  cluster_name                = module.eks.cluster_name
  cluster_security_sg         = module.eks.cluster_security_group_id
  vpc_id                      = module.vpc.vpc_id
  subnet_ids                  = module.vpc.private_subnet_ids
  node_instance_profile_name  = module.iam.node_instance_profile_name
  node_role_arn               = module.iam.node_instance_role_arn
  instance_type               = var.instance_type
  desired_size                = var.node_desired_size
  min_size                    = var.node_min_size
  max_size                    = var.node_max_size
  eks_version                 = var.cluster_version

  depends_on = [null_resource.apply_aws_auth]
}
