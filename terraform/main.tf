provider "aws" {
  region = var.region
}

module "vpc" {
  source              = "./modules/vpc"
  project_name        = var.project_name
  vpc_cidr            = var.vpc_cidr
  public_subnets_cidr = var.public_subnets_cidr
  azs                 = var.azs
}



module "security_group" { 
  source            = "./modules/security-group"
  project_name      = var.project_name
  vpc_id            = module.vpc.vpc_id
  allowed_ssh_cidr  = var.allowed_ssh_cidr
  allowed_http_cidr = ["0.0.0.0/0"]
}

module "alb" {
  source            = "./modules/alb"
  project_name      = var.project_name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnets
  alb_sg_id         = aws_security_group.alb_sg.id
}

resource "aws_security_group" "alb_sg" {
  name   = "${var.project_name}-alb-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "launch_template" {
  source            = "./modules/launch-template"
  project_name      = var.project_name
  ami_id            = var.ami_id
  instance_type     = var.instance_type
  key_name          = var.key_name
  security_group_id = module.security_group.security_group_id
  iam_instance_profile_arn = aws_iam_instance_profile.ec2_cw_profile.arn
}

module "autoscaling" {
  source             = "./modules/autoscaling"
  project_name       = var.project_name
  public_subnets     = module.vpc.public_subnets
  launch_template_id = module.launch_template.launch_template_id
  target_group_arn  = module.alb.target_group_arn
}


module "cloudwatch" {
  source       = "./modules/cloudwatch"
  project_name = var.project_name
  asg_name     = module.autoscaling.asg_name
  alb_arn_suffix = module.alb.alb_arn_suffix
}

# --- IAM Resources para CloudWatch ---

resource "aws_iam_role" "ec2_cw_role" {
  name = "ec2_cloudwatch_agent_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cw_policy_attach" {
  role       = aws_iam_role.ec2_cw_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2_cw_profile" {
  name = "ec2_cw_profile"
  role = aws_iam_role.ec2_cw_role.name
}

terraform {
  backend "s3" {
    bucket         = "terraform-state-app-tf"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    # dynamodb_table = "terraform-state-locking"
    use_lockfile   = true
    encrypt        = true
  }
}

resource "aws_iam_role_policy" "ec2_asg_readonly" {
  name = "ec2_asg_readonly_permissions"
  role = aws_iam_role.ec2_cw_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "autoscaling:DescribeAutoScalingInstances",
          "ec2:DescribeTags"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}