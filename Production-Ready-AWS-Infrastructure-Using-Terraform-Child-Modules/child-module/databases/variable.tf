variable "db_identifier" {}

variable "db_name" {}

variable "username" {}

variable "password" {
  sensitive = true
}

variable "instance_class" {
  default = "db.t3.micro"
}

variable "allocated_storage" {
  default = 20
}

variable "engine_version" {
  default = "8.0"
}

variable "vpc_id" {}

variable "security_group_id" {
  description = "Existing RDS security group ID"
  type        = string
}

variable "private_subnets" {
  type = list(string)
}