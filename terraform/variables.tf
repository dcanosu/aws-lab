variable "region" {
  default = "us-east-1"
}

variable "project_name" {
  default = "app"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnets_cidr" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "azs" {
  type    = list(string)
  default = ["a", "b"]
}

variable "allowed_ssh_cidr" {
  type    = list(string)
  default = ["0.0.0.0/0"] //cambiar por la ip publica
 }

variable "ami_id" {
  description = "Amazon Linux 2 AMI"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "key_name" {
  description = "Existing EC2 Key Pair"
  default     = "mi-llave-docker"
}