module "vpc" {
  source          = "./modules/vpc"
  name            = var.cluster_name
  cidr            = var.vpc_cidr
  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  tags            = var.tags
}

module "iam" {
  source       = "./modules/iam"
  cluster_name = var.cluster_name
  tags         = var.tags
}

module "eks" {
  source                      = "./modules/eks"
  name                        = var.cluster_name
  kubernetes_version          = var.kubernetes_version
  role_arn                    = module.iam.cluster_role_arn
  subnet_ids                  = module.vpc.private_subnet_ids
  tags                        = var.tags
}

module "selfnodes" {
  source                      = "./modules/selfnodes"
  cluster_name                = module.eks.cluster_name
  cluster_version             = var.kubernetes_version
  cluster_endpoint            = module.eks.cluster_endpoint
  cluster_ca                  = module.eks.cluster_ca
  subnet_ids                  = module.vpc.private_subnet_ids
  node_role_arn               = module.iam.node_role_arn
  instance_profile_name       = module.iam.node_instance_profile_name
  instance_type               = var.node_instance_type
  desired_size                = var.node_desired_size
  min_size                    = var.node_min_size
  max_size                    = var.node_max_size
  disk_size                   = var.node_disk_size
  cluster_security_group_id   = module.eks.cluster_security_group_id
  tags                        = var.tags
}

module "aws_auth" {
  source        = "./modules/aws_auth"
  cluster_name  = module.eks.cluster_name
  node_role_arn = module.iam.node_role_arn
  depends_on    = [module.eks]
}
