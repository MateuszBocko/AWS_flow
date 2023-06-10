module "RDS" {
  source = "./modules/RDS"
}

module aws_lambda {
  source = "./modules/aws_lambda"
  DB_endpoint = module.RDS.db_endpoint
  username = module.RDS.username
  password = module.RDS.password
  host = module.RDS.hostname
  port = module.RDS.port
  SUBNET_IDS = module.RDS.SUBNET_IDS[0]
  SECURITY_GROUP_IDS = module.RDS.SECURITY_GROUP_IDS
}
