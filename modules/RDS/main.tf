# configured aws provider with proper credentials
provider "aws" {
  region = "eu-central-1"
}

# create default vpc if one does not exit
resource "aws_default_vpc" "default_vpc" {
  tags = {
    Name = "default vpc"
  }
}

# use data source to get all avalablility zones in region
data "aws_availability_zones" "available_zones" {}


# create a default subnet in the first az if one does not exit
resource "aws_default_subnet" "subnet_az1" {
  availability_zone = data.aws_availability_zones.available_zones.names[0]
}

# create a default subnet in the second az if one does not exit
resource "aws_default_subnet" "subnet_az2" {
  availability_zone = data.aws_availability_zones.available_zones.names[1]
}

# create security groups to allow connection between lambda and RDS
resource "aws_security_group" "lambda_sg" {
  name        = "lambda security group"
  description = "enable access on port 5432"
  vpc_id      = aws_default_vpc.default_vpc.id

  ingress {
    description      = "lambda access port"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags   = {
    Name = "lambda security group"
  }
}

# create security group for the database
resource "aws_security_group" "database_security_group" {
  name        = "database security group"
  description = "enable postgres access on port 5432"
  vpc_id      = aws_default_vpc.default_vpc.id

  ingress {
    description      = "postgres access"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    security_groups  = [aws_security_group.lambda_sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags   = {
    Name = "database security group"
  }
}

# create the subnet group for the rds instance
resource "aws_db_subnet_group" "database_subnet_group" {
  name         = "database-subnets"
  subnet_ids   = [aws_default_subnet.subnet_az1.id, aws_default_subnet.subnet_az2.id]
  description  = "subnets for db instance"

  tags   = {
    Name = "database-subnets"
  }
}

# create the rds instance
resource "aws_db_instance" "db_instance" {
  engine                  = "postgres"
  engine_version          = "13.7"
  multi_az                = false
  identifier              = "dev-rds-instance"
  username                = var.username
  password                = var.password
  instance_class          = "db.t3.micro"
  allocated_storage       = "200"
  db_subnet_group_name    = aws_db_subnet_group.database_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.database_security_group.id]
  availability_zone       = data.aws_availability_zones.available_zones.names[0]
  db_name                 = var.db_name
  publicly_accessible     = true
  skip_final_snapshot     = true
}

# outputs for lambda function
output "db_endpoint" {
  value = "${aws_db_instance.db_instance.endpoint}"
}

output "username" {
  value = var.username
}

output "password" {
  value = var.password
}

output "SUBNET_IDS" {
  value     = [aws_db_subnet_group.database_subnet_group.subnet_ids]
}

output "SECURITY_GROUP_IDS" {
  value     = [aws_security_group.lambda_sg.id]
}

output "hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.db_instance.address
  sensitive   = true
}

output "port" {
  description = "RDS instance port"
  value       = aws_db_instance.db_instance.port
  sensitive   = true
}


