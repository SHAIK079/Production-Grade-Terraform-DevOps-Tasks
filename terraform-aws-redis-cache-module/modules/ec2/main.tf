# Security Group for EC2

resource "aws_security_group" "app" {

  name = "${var.name}-sg"

  vpc_id = var.vpc_id


  # SSH access (testing)

  ingress {

    from_port = 22

    to_port = 22

    protocol = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]

  }


  # Application Port

  ingress {

    from_port = 8080

    to_port = 8080

    protocol = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]

  }



  # Outbound Internet

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





# EC2 Instance

resource "aws_instance" "app" {


  count = var.instance_count



  ami = var.ami_id



  instance_type = var.instance_type



  subnet_id = var.private_subnet_ids[count.index]





  vpc_security_group_ids = [

    aws_security_group.app.id

  ]



  user_data = <<EOF

#!/bin/bash

yum update -y

echo "Application Server Running" > /tmp/app.txt


EOF



  tags = {

    Name = "${var.name}-${count.index + 1}"

  }


}