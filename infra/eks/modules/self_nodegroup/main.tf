data "aws_ssm_parameter" "eks_ami" {
  name = "/aws/service/eks/optimized-ami/${var.eks_version}/amazon-linux-2/recommended/image_id"
}

resource "aws_security_group" "nodes" {
  name        = "${var.cluster_name}-nodes-sg"
  description = "EKS self-managed worker nodes"
  vpc_id      = var.vpc_id

  # Allow traffic from cluster SG to nodes (control plane to kubelet)
  ingress {
    description     = "Allow from cluster SG"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [var.cluster_security_sg]
  }

  # Allow node-to-node
  ingress {
    description                = "Node to node"
    from_port                  = 0
    to_port                    = 0
    protocol                   = "-1"
    self                       = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Allow cluster SG egress to nodes (control plane to kubelet)
resource "aws_security_group_rule" "cluster_to_nodes" {
  type                     = "egress"
  description              = "EKS control plane to nodes"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = var.cluster_security_sg
  source_security_group_id = aws_security_group.nodes.id
}

resource "aws_launch_template" "this" {
  name_prefix   = "${var.cluster_name}-lt-"
  image_id      = data.aws_ssm_parameter.eks_ami.value
  instance_type = var.instance_type
  iam_instance_profile {
    name = var.node_instance_profile_name
  }
  user_data = base64encode(<<-EOT
              #!/bin/bash
              /etc/eks/bootstrap.sh ${var.cluster_name}
              EOT
  )
  vpc_security_group_ids = [aws_security_group.nodes.id]
}

resource "aws_autoscaling_group" "this" {
  name                = "${var.cluster_name}-asg"
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_size
  vpc_zone_identifier = var.subnet_ids

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }
  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-node"
    propagate_at_launch = true
  }
}
