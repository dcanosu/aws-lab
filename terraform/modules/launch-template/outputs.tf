output "launch_template_id" {
  value = aws_launch_template.app_lt.id
}

output "private_key_pem" {
  value     = tls_private_key.rsa_key.private_key_pem
  sensitive = true
}