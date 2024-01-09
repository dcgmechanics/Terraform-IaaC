variable "public_subnet_numbers" {
  type = number
  description = "Map of AZ to a number that should be used for public subnets"
  default = 2
}
 
variable "private_subnet_numbers" {
  type = number
  description = "Map of AZ to a number that should be used for private subnets"
  default = 2
}
 
variable "vpc_cidr" {
  type        = string
  description = "The IP range to use for the VPC"
  default     = "172.0.0.0/16"
}

variable "public_subnet1" {
  type        = string
  description = "The IP range to use for the VPC"
  default     = "172.0.0.0/20"
}

variable "public_subnet2" {
  type        = string
  description = "The IP range to use for the VPC"
  default     = "172.0.16.0/20"
}

variable "private_subnet1" {
  type        = string
  description = "The IP range to use for the VPC"
  default     = "172.0.32.0/20"
}

variable "private_subnet2" {
  type        = string
  description = "The IP range to use for the VPC"
  default     = "172.0.48.0/20"
}
 
variable "infra_env" {}

variable "region" {}

variable "project-name" {}