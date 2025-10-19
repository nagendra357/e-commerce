locals {
  ami_ssm_param = "/aws/service/eks/optimized-ami/${var.cluster_version}/amazon-linux-2/recommended/image_id"
}

data "aws_ssm_parameter" "eks_ami" {
  name = local.ami_ssm_param
}

resource "aws_security_group" "node" {
  name        = "${var.cluster_name}-node-sg"
  description = "EKS self-managed node security group"
  vpc_id      = data.aws_subnet.selected.vpc_id
  tags        = merge(var.tags, { Name = "${var.cluster_name}-node-sg" })
}

data "aws_subnet" "selected" {
  id = var.subnet_ids[0]
}

resource "aws_security_group_rule" "node_egress" {
  security_group_id = aws_security_group.node.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "cluster_to_nodes" {
  security_group_id        = aws_security_group.node.id
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = var.cluster_security_group_id
}

resource "aws_security_group_rule" "nodes_to_cluster" {
  security_group_id        = var.cluster_security_group_id
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.node.id
}

resource "aws_launch_template" "node" {
  name_prefix   = "${var.cluster_name}-lt-"
  image_id      = data.aws_ssm_parameter.eks_ami.value
  instance_type = var.instance_type

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = var.disk_size
      volume_type = "gp3"
      delete_on_termination = true
    }
  }

  iam_instance_profile {
    name = var.instance_profile_name
  }

  network_interfaces {
    security_groups = [aws_security_group.node.id]
  }

  user_data = base64encode(<<-EOT
              #!/bin/bash
              set -o xtrace
              /etc/eks/bootstrap.sh ${var.cluster_name} --kubelet-extra-args "--node-labels=node.kubernetes.io/lifecycle=normal"
              EOT)

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, { Name = "${var.cluster_name}-node" })
  }
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

resource "aws_autoscaling_group" "node" {
  name                      = "${var.cluster_name}-asg"
  desired_capacity          = var.desired_size
  min_size                  = var.min_size
  max_size                  = var.max_size
  vpc_zone_identifier       = var.subnet_ids

  launch_template {
    id      = aws_launch_template.node.id
    version = "$Latest"
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

output "node_asg_name" { value = aws_autoscaling_group.node.name }
