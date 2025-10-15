variable "region" {
  description = "AWS region"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "EKS cluster version"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "azs" {
  description = "List of Availability Zones "
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  type        = list(string)
}

variable "node_desired_size" {
  description = "Desired nodes"
  type        = number
}

variable "node_min_size" {
  description = "Min nodes"
  type        = number
}

variable "node_max_size" {
  description = "Max nodes"
  type        = number
}

variable "instance_type" {
  description = "EC2 instance type for nodes"
  type        = string
}
