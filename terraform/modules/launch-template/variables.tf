variable "project_name" {}
variable "ami_id" {}
variable "instance_type" { default = "t3.micro" }
variable "key_name" {}
variable "security_group_id" {}
variable "docker_image_name"{ default = "dcanosu/app-time" }
variable "iam_instance_profile_arn" {
  description = "ARN del Instance Profile para CloudWatch"
  type        = string
}