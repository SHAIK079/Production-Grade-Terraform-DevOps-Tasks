output "vpc_id" {

  value = module.vpc.vpc_id

}


output "private_subnet_ids" {

  value = module.vpc.private_subnet_ids

}


output "ec2_instance_ids" {

  value = module.ec2.instance_ids

}


output "redis_endpoint" {

  value = module.redis.redis_endpoint

}