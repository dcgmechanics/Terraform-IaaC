variable "infra_env" {
  type        = string
  description = "infrastructure environment"
  default     = "dev"
}

variable "region" {
  default     = "us-east-2"
  description = "AWS Dev Region"
}

variable "project-name" {
  default = "project"
}

variable "bucket_name" {
  default = "project-dev"
}