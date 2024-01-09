variable "rds_vpc" {
    description = "VPC"
    type = string
}

variable "vpc_private_subnet1" {
    description = "Private Subnet 1"
    type = string
}

variable "vpc_private_subnet2" {
    description = "Private Subnet 2"
    type = string
}

variable "infra_env" {}

variable "region" {}

variable "project-name" {}