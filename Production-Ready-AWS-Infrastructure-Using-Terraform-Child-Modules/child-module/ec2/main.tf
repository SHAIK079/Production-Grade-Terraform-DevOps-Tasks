##############################################
# APPLICATION SERVER
##############################################


resource "aws_instance" "app_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]

  user_data = <<-EOF
#!/bin/bash
echo "DB_HOST=${var.db_host}" >> /etc/environment
echo "DB_PORT=${var.db_port}" >> /etc/environment
echo "DB_NAME=${var.db_name}" >> /etc/environment
EOF

  tags = {
    Name = var.instance_name
  }
}