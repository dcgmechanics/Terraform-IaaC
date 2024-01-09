# create security group for the database
resource "aws_security_group" "rds_sg" {
  name        = "${var.project-name}-${var.infra_env}-rds security group"
  description = "enable mysql/aurora access on port 3306"
  vpc_id      = var.rds_vpc

  ingress {
    description      = "mysql/aurora access"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project-name}-${var.infra_env}-rds security group"
    Project     = "${var.project-name}.com"
    Environment = var.infra_env
    ManagedBy   = "dcgmechanics"
  }
}

# create the subnet group for the rds instance
resource "aws_db_subnet_group" "database_subnet_group" {
  name         = "${var.project-name}-${var.infra_env}-rds subnet group"
  subnet_ids   = [var.vpc_private_subnet1, var.vpc_private_subnet2]
  description  = "${var.project-name}-${var.infra_env}-rds private subnet group"

  tags = {
    Name = "${var.project-name}-${var.infra_env}-rds subnet group"
    Project     = "${var.project-name}.com"
    Environment = var.infra_env
    ManagedBy   = "dcgmechanics"
  }
}