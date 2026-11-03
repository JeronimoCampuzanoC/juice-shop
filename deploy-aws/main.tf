terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC y subredes por defecto de la cuenta: AWS Academy ya las trae, no hace falta crear red propia.
data "aws_vpc" "default" {
  default = true
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# Juice Shop es vulnerable a proposito: solo se expone a la IP de quien despliega.
resource "aws_security_group" "juice_shop" {
  name        = "${var.project_name}-sg"
  description = "Juice Shop (app vulnerable): acceso solo desde la IP del estudiante"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Juice Shop"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }

  dynamic "ingress" {
    for_each = var.key_name == null ? [] : [1]
    content {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidrs
    }
  }

  egress {
    description = "Salida libre (descarga de Docker e imagen)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-sg"
    Project = var.project_name
  }
}

resource "aws_instance" "juice_shop" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.juice_shop.id]

  # IMDSv2 obligatorio: evita robo de credenciales por SSRF contra el metadata service.
  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  user_data = <<-EOT
    #!/bin/bash
    dnf install -y docker
    systemctl enable --now docker
    docker run -d --name juice-shop --restart unless-stopped -p 3000:3000 ${var.juice_shop_image}
  EOT

  user_data_replace_on_change = true

  # Amazon publica AMIs nuevas seguido; sin esto cada plan querria recrear la instancia.
  lifecycle {
    ignore_changes = [ami]
  }

  tags = {
    Name    = var.project_name
    Project = var.project_name
  }
}
