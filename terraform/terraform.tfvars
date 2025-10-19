region = "us-east-1"
cluster_name = "my-eks"
kubernetes_version = "1.33

vpc_cidr = "10.0.0.0/16"
azs = ["us-east-1a", "us-east-1b"]
public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]

node_instance_type = "t3.medium"
node_desired_size = 2
node_min_size = 1
node_max_size = 3
node_disk_size = 20

tags = {
  Project = "E-commerce"
  Env     = "dev"
}
