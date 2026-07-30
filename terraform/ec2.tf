# We create two vms (one for bastion and the other for our app)

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]   # Canonical's official AWS account ID — publishes real Ubuntu AMIs

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"               
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [ aws_security_group.bastion.id ]
  key_name               = aws_key_pair.bastion_agent.key_name

  tags = {
    Name = "bastion"
  }
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [ aws_security_group.app.id ]
  key_name               = aws_key_pair.app_instance.key_name

  tags = {
    Name = "app-vm"
  }
}

resource "aws_key_pair" "bastion_agent" {
  key_name   = "bastion_agent"
  public_key = file("~/.ssh/bastion_agent.pub")
}

resource "aws_key_pair" "app_instance" {
  key_name   = "app_instance"
  public_key = file("~/.ssh/app_instance.pub")
}