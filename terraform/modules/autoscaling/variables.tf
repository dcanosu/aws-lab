variable "project_name" {}
variable "public_subnets" { type = list(string) }
variable "launch_template_id" {}
variable "desired" { default = 1 }
variable "min" { default = 1 }
variable "max" { default = 2 }
variable "target_group_arn" {
  type = string
}