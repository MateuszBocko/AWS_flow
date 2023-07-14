variable "DB_endpoint" {
  type=string
  default=" "
}

variable "db_name" {
  type=string
  default=" "
}

variable "s3_bucket_name" {
  type=string
  default=" "
}

variable "username" {
  type=string
  default=" "
}

variable "password" {
  type=string
  default=" "
}

variable "host" {
  type=string
  default=" "
}

variable "port" {
  type=string
  default=" "
}

variable "SUBNET_IDS" {
  type=list(string)
}

variable "SECURITY_GROUP_IDS" {
  type=list(string)
}