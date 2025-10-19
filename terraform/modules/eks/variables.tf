variable "name" { type = string }
variable "kubernetes_version" { type = string }
variable "role_arn" { type = string }
variable "subnet_ids" { type = list(string) }
variable "tags" { type = map(string) default = {} }
