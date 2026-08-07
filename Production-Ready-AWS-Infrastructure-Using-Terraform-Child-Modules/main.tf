module "vpc" {
  source = "./child-module/vpc"

  aws_region             = "us-east-1"
  vpc_cidr               = "10.0.0.0/16"
  vpc_name               = "prod-vpc"
  public_subnet_1_cidr   = "10.0.1.0/24"
  public_subnet_2_cidr   = "10.0.2.0/24"
  private_subnet_5_cidr  = "10.0.7.0/24"
  private_subnet_6_cidr  = "10.0.8.0/24"
  availability_zone_1a   = "us-east-1a"
  availability_zone_1b   = "us-east-1b"
  allowed_ssh_cidr       = ["0.0.0.0/0"]
}


##############################################
# RDS CHILD MODULE
##############################################

module "rds" {
  source = "./child-module/databases"

  # Database Configuration
  db_identifier     = "production-mysql"
  db_name           = "appdb"
  username          = "admin"
  password          = "shaiksami123"

  # RDS Configuration
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  engine_version    = "8.0"

  # Networking
  vpc_id            = module.vpc.vpc_id
  private_subnets  = module.vpc.private_db_subnets
  security_group_id = module.vpc.database_sg_id
}

module "ec2" {
  source = "./child-module/ec2"

  ami_id            = "ami-04b70fa74e45c3917"
  instance_type     = "t3.micro"

  # Launch EC2 in Public Subnet
  subnet_id         = module.vpc.public_subnet_1_id

  # Attach Bastion Security Group
  security_group_id = module.vpc.bastion_sg_id

  # RDS Details
  db_host           = module.rds.endpoint
  db_port           = module.rds.port
  db_name           = "appdb"

  instance_name     = "Application-Server"
}