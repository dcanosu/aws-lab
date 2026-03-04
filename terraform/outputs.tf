output "asg_name" {
  value = module.autoscaling.asg_name
}

output "ssh_private_key" {
  value     = module.launch_template.private_key_pem
  sensitive = true
}