variable "rate" {
  type = string
  default = "6"
}

variable "metric" {
  type = string
  default = "hours" # can be minutes, hours, days
}

variable "region" {
  type = string
  default = "us-east-2"
}

variable "accountNumber" {
  type = string
}

variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
}