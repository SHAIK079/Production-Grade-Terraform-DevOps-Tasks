terraform {

  required_providers {

    aws = {

      source = "hashicorp/aws"

      version = "~> 6.0"

    }

  }

}


provider "aws" {

  region = "us-east-1"

}

module "vpc" {


  source = "../../modules/vpc"



  name = "dev"



  vpc_cidr = "10.0.0.0/16"



  azs = [

    "us-east-1a",

    "us-east-1b"

  ]



  public_subnet_cidrs = [

    "10.0.1.0/24",

    "10.0.2.0/24"

  ]



  private_subnet_cidrs = [

    "10.0.11.0/24",

    "10.0.12.0/24"

  ]


}


module "ec2" {


  source = "../../modules/ec2"



  name = "sam-app"



  vpc_id = module.vpc.vpc_id



  private_subnet_ids = module.vpc.private_subnet_ids



  ami_id = "ami-002192a70217ac181"



  instance_type = "t3.micro"




  instance_count = 2




}


module "redis" {


  source = "../../modules/redis"



  name = "sam-redis"



  vpc_id = module.vpc.vpc_id



  private_subnet_ids = module.vpc.private_subnet_ids



  ec2_security_group_id = module.ec2.security_group_id



  node_type = "cache.t3.micro"


}