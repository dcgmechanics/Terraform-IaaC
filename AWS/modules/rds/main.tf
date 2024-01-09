resource "aws_db_instance" "mysql_rds" {
  allocated_storage    = 10
  identifier          = "${var.project-name}-${var.infra_env}-rds"
  db_name              = "devdb"
  engine               = "mysql"
  engine_version       = "8.0.33"
  instance_class       = "db.t4g.small"
  username             = "devdbuser"
  password             = "devdbpass123"
  multi_az             = true
  db_subnet_group_name    = aws_db_subnet_group.database_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true

  tags = {
    Name        = "${var.project-name}-${var.infra_env}-vpc"
    Project     = "${var.project-name}.com"
    Environment = var.infra_env
    ManagedBy   = "dcgmechanics"
  }
}