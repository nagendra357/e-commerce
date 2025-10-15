output "cluster_role_arn" { value = aws_iam_role.cluster.arn }
output "node_instance_role_arn" { value = aws_iam_role.node.arn }
output "node_instance_role_name" { value = aws_iam_role.node.name }
output "node_instance_profile_name" { value = aws_iam_instance_profile.node.name }
