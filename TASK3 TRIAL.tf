provider "aws" {
	region = "ap-south-1"
        access_key = "AKIA6BH2VXLX2WZG2C4R"
	secret_key = "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"
}

//---------------------------------------------------------------
resource "aws_vpc" "task-3" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  
  tags = {
    Name = "task-3"
  }
}
//--------------------------------------------------------------
resource "aws_subnet" "subnet-1a-public" {
  vpc_id     = aws_vpc.task-3.id
  cidr_block = "192.168.1.0/24"
  availability_zone = "ap-south-1a" //ap-south-1b ap-south-1c
  map_public_ip_on_launch = true
  
  tags = {
    Name = "subnet-1a-public"
  }
}
//--------------------------------------------------------------
resource "aws_subnet" "subnet-1a-private" {
  vpc_id     = aws_vpc.task-3.id
  cidr_block = "192.168.2.0/24"
  availability_zone = "ap-south-1a"  //ap-south-1b ap-south-1c
  map_public_ip_on_launch = false
  
  tags = {
    Name = "subnet-1b-private"
  }
}
//--------------------------------------------------------------
resource "aws_security_group" "private-sg" {
  vpc_id       = aws_vpc.task-3.id
  name         = "private-sg"
  description  = "private Mysql"
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    description = "TLS from SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }

  ingress {
    description = "TLS from mysql"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.task-3.cidr_block]
  }

tags = {
   Name = "private-sg"
   Description = "private Mysql"
     }
}
//--------------------------------------------------------------
resource "aws_security_group" "public-sg" {
  vpc_id       = aws_vpc.task-3.id
  name         = "public-sg"
  description  = "public wordpress"
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "TLS from SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

tags = {
   Name = "public-sg"
   Description = "public wordpress"
     }
}
//-------------------------------------------------------------

resource "aws_internet_gateway" "task-3-igw" {
 vpc_id = aws_vpc.task-3.id
 tags = {
        Name = "My task -3 VPC Internet Gateway"
     }
}
//-------------------------------------------------------------

resource "aws_route_table" "route-table" {
  vpc_id = aws_vpc.task-3.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.task-3-igw.id
  }

  tags = {
    Name = "route-table"
  }
}

//-------------------------------------------------------------
resource "aws_route_table_association" "public-association" {
  subnet_id      = aws_subnet.subnet-1a-public.id
  route_table_id = aws_route_table.route-table.id
}
//--------------------------------------------------------------

resource "aws_instance" "mysqlec2" {

  ami           = "ami-08706cb5f68222d09"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.private-sg.id]
  subnet_id = aws_subnet.subnet-1a-private.id
  user_data     = file("mysql.sh")
  

tags = {
    Name = "mysqlec2"
  }
}
//--------------------------------------------------------------

resource "aws_instance" "wordpressec2" {

  ami           = "ami-08706cb5f68222d09"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.public-sg.id]
  subnet_id = aws_subnet.subnet-1a-public.id
  user_data     = file("wordpress.sh")
  

tags = {
    Name = "wordpressec2"
  }
}
//---------------------------------------------------------------

output "wordpress_public_IP"{
  value = aws_instance.wordpressec2.public_ip
}

output "wordpress_public_DNShostname"{
  value = aws_instance.wordpressec2.public_dns
}
















