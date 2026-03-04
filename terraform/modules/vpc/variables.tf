variable "project_name" {
  description = "Project name used for tagging"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_subnets_cidr" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "azs" {
  description = "Availability zone suffixes (a, b, c)"
  type        = list(string)
}