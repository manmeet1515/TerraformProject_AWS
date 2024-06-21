variable "vpc_cidr" {
  default = "10.11.0.0/16"
}

variable "aws_subnet1_AZa" {
  description = "Value for public subnet 1"
  type        = string
  default = "10.11.10.0/24"
}

variable "aws_subnet2_AZb" {
  description = "value for public subnet 2"
  type        = string
  default = "10.11.20.0/24"
}

variable "variable_sub_AZa" {
  description = "Public subnet 1 Availability zone"
  type        = string
  default = "us-east-1a"
}

variable "variable_sub_AZb" {
  description = "Public Subnet 2 availability zone"
  type        = string
  default = "us-east-1b"
}

