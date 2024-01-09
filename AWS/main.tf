module "eks" {
  source       = "./modules/eks"
  region       = var.region
  infra_env    = var.infra_env
  project-name = var.project-name
  eks_name     = "${var.project-name}-${var.infra_env}-eks"
  subnet_ids = [
    module.vpc.vpc_public_subnet1,
    module.vpc.vpc_public_subnet2,
    module.vpc.vpc_private_subnet1,
    module.vpc.vpc_private_subnet2
  ]
}

module "rds" {
  source              = "./modules/rds"
  region              = var.region
  infra_env           = var.infra_env
  project-name        = var.project-name
  rds_vpc             = module.vpc.vpc_id
  vpc_private_subnet1 = module.vpc.vpc_private_subnet1
  vpc_private_subnet2 = module.vpc.vpc_private_subnet2
}

module "s3" {
  source       = "./modules/s3"
  region       = var.region
  infra_env    = var.infra_env
  project-name = var.project-name
  bucket_name  = var.bucket_name #S3 Bucket name should be unique
}

module "sqs" {
  source       = "./modules/sqs"
  region       = var.region
  infra_env    = var.infra_env
  project-name = var.project-name
}

module "vpc" {
  source       = "./modules/vpc"
  region       = var.region
  infra_env    = var.infra_env
  project-name = var.project-name
  vpc_cidr     = "172.10.0.0/16"
}