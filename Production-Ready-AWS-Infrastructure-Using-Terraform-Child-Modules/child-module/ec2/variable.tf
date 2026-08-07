variable "ami_id" {}

variable "instance_type" {}

variable "subnet_id" {}

variable "security_group_id" {
  description = "Security group ID for the EC2 instance"
  type        = string
}

variable "db_host" {}

variable "db_port" {}

variable "db_name" {}

variable "instance_name" {}