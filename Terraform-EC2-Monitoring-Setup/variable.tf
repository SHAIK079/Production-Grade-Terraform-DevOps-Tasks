variable "ami_id" {
  type    = string
  default = "ami-004f790b835b26145"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  description = "Existing AWS EC2 key pair name"
  type        = string
  default     = "sam-key"
}

variable "private_key_path" {
  description = "Path to the private SSH key"
  type        = string
  default     = "~/.ssh/id_ed25519"
}

variable "application_servers" {
  type = list(string)

  default = [
    "10.0.2.15:9100",
    "10.0.3.20:9100"
  ]
}