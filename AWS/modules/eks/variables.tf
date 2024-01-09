variable "infra_env" {}

variable "k8s-ver" {
  default     = "1.28"
  description = "K8s Version"
}

variable "region" {}

variable "eks_name" {}

variable "project-name" {}

variable "subnet_ids" {   
  description = "List of ids for subnets in the VPC"
  type= list(string) 
  }

# variable "public_subnet1_id" {
#   type = string
# }
# variable "public_subnet2_id" {
#   type = string
# }
# variable "private_subnet1_id" {
#   type = string
# }
# variable "private_subnet2_id" {
#   type = string
# }