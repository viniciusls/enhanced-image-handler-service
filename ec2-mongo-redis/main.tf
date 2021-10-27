locals {
  only_in_production_mapping = {
    dev     = 0
    staging = 0
    prod    = 1
  }
  only_in_production = local.only_in_production_mapping[terraform.workspace]
}

# Create EC2 Mongo Redis security group
resource "aws_security_group" "ec2_mongo_redis_sg" {
  count  = local.only_in_production
  vpc_id = var.vpc_id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2_mongo_redis" {
  count                       = local.only_in_production
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = var.key_name
  security_groups = [
    aws_security_group.ec2_mongo_redis_sg.name
  ]

  credit_specification {
    cpu_credits = "unlimited"
  }

  root_block_device {
    volume_size = 10
    volume_type = "gp2"
  }

  tags = {
    Name = "EC2 Mongo Redis"
  }
}
