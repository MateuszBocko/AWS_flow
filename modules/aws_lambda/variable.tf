variable "DB_endpoint" {
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