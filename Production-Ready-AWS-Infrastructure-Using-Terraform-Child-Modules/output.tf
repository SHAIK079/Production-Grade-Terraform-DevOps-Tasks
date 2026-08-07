output "rds_endpoint" {
  value = module.rds.endpoint
}

output "rds_port" {
  value = module.rds.port
}

output "app_server_id" {
  value = module.ec2.instance_id
}

output "app_server_private_ip" {
  value = module.ec2.private_ip
}

output "vpc_id" {
  value = module.vpc.vpc_id
}
