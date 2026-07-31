# specify who can access our vm via the ssh
resource "aws_security_group" "bastion" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # It's open to the world
  }

  # public entrypoint - nginx on bastion proxies to the app vm
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Can talk to any one outside
  }
}


resource "aws_security_group" "app" {
  vpc_id = aws_vpc.main.id

   # Allow bastion ssh
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [ aws_security_group.bastion.id ]
  } 

  # backend
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [ aws_security_group.bastion.id ]  
  }

  #frontend
  ingress {
    from_port       = 5173
    to_port         = 5173
    protocol        = "tcp"
    security_groups = [ aws_security_group.bastion.id ]  
  }

  #internet access
  ingress {
    from_port   = 80        
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Can talk to any one outside
  }
}

resource "aws_security_group" "rds" {
  vpc_id = aws_vpc.main.id

  # postgres
  ingress {
    from_port       = 5432     
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [ aws_security_group.app.id ]   # only app VM, nothing else
  }

   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Can talk to any one outside
  }
}