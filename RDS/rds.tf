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
  username                = "temporary_user"
  password                = "temporary_password"
  instance_class          = "db.t3.micro"
  allocated_storage       = "200"
  db_subnet_group_name    = aws_db_subnet_group.database_subnet_group.name
  availability_zone       = data.aws_availability_zones.available_zones.names[0]
  db_name                 = "videotrendingdb"
  publicly_accessible     = true
  skip_final_snapshot     = true
}

# save endpoint to db
resource "local_file" "private_key" {
    content  = "${aws_db_instance.db_instance.endpoint}"
    filename = "private_key.txt"
}