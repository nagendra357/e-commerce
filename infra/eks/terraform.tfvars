region              = "us-east-1"
cluster_name        = "demo-eks"
cluster_version     = "1.33"

vpc_cidr            = "10.0.0.0/16"
azs                 = ["us-east-1a", "us-east-1b"]

public_subnet_cidrs  = ["10.0.0.0/24", "10.0.1.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]

# Self-managed node group settings
instance_type       = "t2.micro"
node_min_size       = 1
node_desired_size   = 2
node_max_size       = 3
