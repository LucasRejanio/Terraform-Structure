provider "aws" {
  region = "${var.region}"
}

#VPC: Rede dentro da AWS
resource "aws_vpc" "vpc" {
  cidr_block = "${var.cidr_block}"

  tags = {
    Name = "VPC-Infraestruture"
  }
}

#Internet Gateway: Interligação com a rede externa
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "IT-Infraestruture"
  }
}

#Subnets: Divisão da sua VPC
#Subnets Public
resource "aws_subnet" "public_a" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.cidr_block_subnet_public_a}"
  availability_zone = "${var.region}a"

  tags = {
    Name = "Subnet-A-Public"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.cidr_block_subnet_public_b}"
  availability_zone = "${var.region}b"

  tags = {
    Name = "Subnet-B-Public"
  }
}

#Subnets Private 
resource "aws_subnet" "private_a" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.cidr_block_subnet_private_a}"
  availability_zone = "${var.region}a"

  tags = {
    Name = "Subnet-A-Private"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.cidr_block_subnet_private_b}"
  availability_zone = "${var.region}b"

  tags = {
    Name = "Subnet-B-Private"
  }
}

#Route Table: Tabela de roteamente que faz a parte de direcionamento e comunicação
#Router Table Public
resource "aws_route_table" "rt-public" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags = {
    Name = "RT-Public"
  }
}

#Router Table Private 
resource "aws_route_table" "rt-private" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "RT-Private"
  }
}

#Associação entre a subnet e a tabela de roteamento 
#Associação Subnet Public 
resource "aws_route_table_association" "rt-public-a" {
  subnet_id      = "${aws_subnet.public_a.id}"
  route_table_id = "${aws_route_table.rt-public.id}"
}

resource "aws_route_table_association" "rt-public-b" {
  subnet_id      = "${aws_subnet.public_b.id}"
  route_table_id = "${aws_route_table.rt-public.id}"
}

#Associação Subnet Private
resource "aws_route_table_association" "rt-privat-a" {
  subnet_id      = "${aws_subnet.private_a.id}"
  route_table_id = "${aws_route_table.rt-private.id}"
}

resource "aws_route_table_association" "rt-private-b" {
  subnet_id      = "${aws_subnet.private_b.id}"
  route_table_id = "${aws_route_table.rt-private.id}"
}

#Security Groups
resource "aws_security_group" "web" {
  name        = "web"
  description = "Allow public inbound traffic"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 80 #http
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443 #https
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["${var.cidr_block}"]
  }

  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr_block_subnet_private_a}"]
  }

  tags = {
    Name = "Web-Servers"
  }
}

resource "aws_security_group" "db" {
  name        = "db"
  description = "Allow database inbound traffic"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.web.id}"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["${var.cidr_block}"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Database"
  }
}




