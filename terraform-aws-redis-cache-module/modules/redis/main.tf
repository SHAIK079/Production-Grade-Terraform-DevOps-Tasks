# Redis subnet group
# Redis will run only inside private subnets

resource "aws_elasticache_subnet_group" "redis" {


  name = "${var.name}-subnet-group"



  subnet_ids = var.private_subnet_ids


}




# Redis Security Group

resource "aws_security_group" "redis" {


  name = "${var.name}-sg"



  vpc_id = var.vpc_id



  # Redis Port

  ingress {


    from_port = 6379


    to_port = 6379


    protocol = "tcp"



    security_groups = [

      var.ec2_security_group_id

    ]


  }



  # Outbound traffic

  egress {


    from_port = 0


    to_port = 0


    protocol = "-1"



    cidr_blocks = [

      "0.0.0.0/0"

    ]

  }



  tags = {


    Name = "${var.name}-sg"


  }


}





# Redis Replication Group

resource "aws_elasticache_replication_group" "redis" {


  replication_group_id = var.name



  description = "Application Redis Cache"



  engine = "redis"



  engine_version = "7.0"



  node_type = var.node_type



  # Primary + Replica

  num_cache_clusters = 2



  # Automatic failover

  automatic_failover_enabled = true



  # Multi AZ

  multi_az_enabled = true



  subnet_group_name = aws_elasticache_subnet_group.redis.name



  security_group_ids = [

    aws_security_group.redis.id

  ]



  port = 6379



  # Backup

  snapshot_retention_limit = 7



  # Encryption

  at_rest_encryption_enabled = true



  transit_encryption_enabled = true


}
