variable "region" {
    description = "East Cost region on the AWS"
    type = string
    default = "us-east-1"
}

variable "db_password" {
  type      = string
  sensitive = true
}
