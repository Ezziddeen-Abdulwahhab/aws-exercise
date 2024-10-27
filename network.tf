resource "aws_vpc" "webapp_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "webapp-vpc"
  }
}

resource "aws_docdb_subnet_group" "webapp_subnet_group" {
  name       = "webapp-subnet-group"
  subnet_ids = [aws_subnet.webapp_subnet.id]

  tags = {
    Name = "webapp-subnet-group"
  }
}

resource "aws_subnet" "webapp_subnet" {
  vpc_id            = aws_vpc.webapp_vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "eu-north-1"

  tags = {
    Name = "webapp_subnet"
  }
}

resource "aws_network_interface" "webapp_interface" {
  subnet_id   = aws_subnet.webapp_subnet.id
  private_ips = ["172.16.10.100"]

  tags = {
    Name = "webapp_interface"
  }
}

resource "aws_security_group" "webapp_security_group" {
  name   = "webapp_security_group"
  vpc_id = aws_vpc.webapp_vpc.id

  tags = {
    Name = "webapp-security-group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_webapp_http" {
  security_group_id = aws_security_group.webapp_security_group.id
  cidr_ipv4         = aws_vpc.webapp_vpc.cidr_block
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}
