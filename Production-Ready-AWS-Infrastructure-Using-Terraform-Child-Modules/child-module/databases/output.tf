output "endpoint" {

  value = aws_db_instance.primary.endpoint

}

output "reader_endpoint" {

  value = aws_db_instance.replica.endpoint

}

output "port" {

  value = aws_db_instance.primary.port

}

output "security_group" {

  value = var.security_group_id

}