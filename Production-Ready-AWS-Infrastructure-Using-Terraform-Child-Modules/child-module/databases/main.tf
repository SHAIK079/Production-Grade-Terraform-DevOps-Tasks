resource "aws_db_subnet_group" "this" {

  name = "${var.db_identifier}-subnet"

  subnet_ids = var.private_subnets

}


resource "aws_db_instance" "primary" {

  identifier = var.db_identifier

  engine = "mysql"

  engine_version = var.engine_version

  instance_class = var.instance_class

  allocated_storage = var.allocated_storage

  storage_type = "gp3"

  storage_encrypted = true

  db_name = var.db_name

  username = var.username

  password = var.password

  skip_final_snapshot = false

  deletion_protection = true

  backup_retention_period = 1

  backup_window = "03:00-04:00"

  maintenance_window = "Mon:04:00-Mon:05:00"

  publicly_accessible = true

  multi_az = true

  db_subnet_group_name = aws_db_subnet_group.this.name

  vpc_security_group_ids = [
    var.security_group_id
  ]
}

resource "aws_db_instance" "replica" {

  identifier = "${var.db_identifier}-replica"

  replicate_source_db = aws_db_instance.primary.identifier

  instance_class = var.instance_class

  publicly_accessible = false

  storage_encrypted = true

  skip_final_snapshot = true

}

