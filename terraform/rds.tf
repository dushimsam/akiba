resource "aws_db_subnet_group" "main" {
  name       = "rds_subnet_group"
  subnet_ids = [ aws_subnet.private.id, aws_subnet.private_b.id ]   # needs at least 2 subnets, in different AZs
}

resource "aws_db_instance" "main" {
  identifier             = "akiba-db"
  engine                 = "postgres"   
  engine_version         = "18"
  instance_class         = "db.t3.micro"  
  allocated_storage      = 20
  db_name                = "akiba"
  username               = "akiba"
  password               = var.db_password     
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [ aws_security_group.rds.id ] 
  skip_final_snapshot    = true 
}

