output "monitoring_instance_id" {
  description = "Monitoring EC2 instance ID"
  value       = aws_instance.monitoring.id
}

output "monitoring_public_ip" {
  description = "Public IP address of monitoring server"
  value       = aws_instance.monitoring.public_ip
}

output "monitoring_private_ip" {
  description = "Private IP address of monitoring server"
  value       = aws_instance.monitoring.private_ip
}

output "prometheus_url" {
  description = "Prometheus web interface"
  value       = "http://${aws_instance.monitoring.public_ip}:9090"
}

output "grafana_url" {
  description = "Grafana web interface"
  value       = "http://${aws_instance.monitoring.public_ip}:3000"
}

output "node_exporter_url" {
  description = "Node Exporter metrics endpoint"
  value       = "http://${aws_instance.monitoring.public_ip}:9100/metrics"
}

output "ssh_command" {
  description = "SSH command to connect to monitoring server"
  value       = "ssh -i ${pathexpand(var.private_key_path)} ec2-user@${aws_instance.monitoring.public_ip}"
}

output "vpc_id" {
  description = "Monitoring VPC ID"
  value       = aws_vpc.my_vpc.id
}

output "subnet_id" {
  description = "Monitoring public subnet ID"
  value       = aws_subnet.public.id
}

output "security_group_id" {
  description = "Monitoring security group ID"
  value       = aws_security_group.monitoring.id
}