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

variable "target_regions" {
  type = string
  default = "us-east-2, us-west-2, us-east-1"
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