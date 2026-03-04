variable "project_name" {}
variable "vpc_id" {}
variable "ssh_port" { default = 22 }
variable "http_port" { default = 80 }
variable "allowed_ssh_cidr" { type = list(string) }
variable "allowed_http_cidr" { type = list(string) }