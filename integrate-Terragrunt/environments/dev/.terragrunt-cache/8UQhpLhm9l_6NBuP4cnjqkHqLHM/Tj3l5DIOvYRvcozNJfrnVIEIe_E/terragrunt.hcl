terraform {
  source = "../../modules/ec2"
}

inputs = {
  instance_type = "t3.micro"
  ami_id        = "ami-004f790b835b26145"
}