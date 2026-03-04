########################
# 1. Generación de Llave SSH
########################

# Genera la llave privada (en memoria de Terraform)
resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Crea la Key Pair en AWS usando la parte pública
resource "aws_key_pair" "deployer" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.rsa_key.public_key_openssh
}

# Guarda la llave privada en un archivo .pem local para que puedas usarla
resource "local_file" "private_key" {
  content         = tls_private_key.rsa_key.private_key_pem
  filename        = "${path.module}/${var.project_name}-key.pem"
  file_permission = "0400" 
}

########################
# 2. Launch Template
########################

resource "aws_launch_template" "app_lt" {
  name_prefix   = "${var.project_name}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type


  # AQUÍ conectamos con la llave creada arriba
  key_name      = aws_key_pair.deployer.key_name

  iam_instance_profile {
    arn = var.iam_instance_profile_arn
  }

  vpc_security_group_ids = [var.security_group_id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y python3
              EOF
  )


  # user_data = base64encode(<<-EOF
  #             #!/bin/bash
  #             yum update -y
  #             amazon-linux-extras install docker -y
  #             systemctl start docker
  #             systemctl enable docker
  #             # Usamos la variable de la imagen que definimos antes
  #             docker run -d -p 80:80 --name app ${var.docker_image_name}
  #             EOF
  # )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-instance"
    }
  }

  # Recomendado para evitar errores al actualizar
  lifecycle {
    create_before_destroy = true
  }
}