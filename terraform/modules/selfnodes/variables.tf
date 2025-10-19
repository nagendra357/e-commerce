variable "cluster_name" { type = string }
variable "cluster_version" { type = string }
variable "cluster_endpoint" { type = string }
variable "cluster_ca" { type = string }
variable "subnet_ids" { type = list(string) }
variable "node_role_arn" { type = string }
variable "instance_type" { type = string }
variable "desired_size" { type = number }
variable "min_size" { type = number }
variable "max_size" { type = number }
variable "disk_size" { type = number }
variable "cluster_security_group_id" { type = string }
variable "instance_profile_name" { type = string }
variable "tags" { type = map(string) default = {} }
