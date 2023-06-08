module "RDS" {
  source = "./modules/RDS"
}

module aws_lambda {
  source = "./modules/aws_lambda"
  DB_endpoint = module.RDS.db_endpoint
  username = module.RDS.username
  password = module.RDS.password
}
