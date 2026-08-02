variable "name" {

  type = string

}



variable "vpc_id" {

  type = string

}



variable "private_subnet_ids" {

  type = list(string)

}



variable "ami_id" {

  type = string

}



variable "instance_type" {

  type = string

  default = "t2.micro"

}



variable "instance_count" {

  type = number

  default = 2

}