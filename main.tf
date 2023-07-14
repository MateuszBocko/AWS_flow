module "RDS" {
  source = "./modules/RDS"
}

module "S3" {
  source = "./modules/S3"
}

module aws_lambda {
  source = "./modules/aws_lambda"
  DB_endpoint = module.RDS.db_endpoint
  db_name = module.RDS.db_name
  username = module.RDS.username
  password = module.RDS.password
  host = module.RDS.hostname
  port = module.RDS.port
  SUBNET_IDS = module.RDS.SUBNET_IDS[0]
  SECURITY_GROUP_IDS = module.RDS.SECURITY_GROUP_IDS
  s3_bucket_name = module.S3.s3_bucket_name
}