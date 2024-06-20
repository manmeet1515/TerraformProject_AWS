locals {
  dev_env = "Dev"
}

resource "aws_vpc" "VPC" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name    = "${local.dev_env}-vpc"
    Purpose = "Deployment using Terraform"
  }
}

resource "aws_subnet" "PublicSubnet1" {
  vpc_id                  = aws_vpc.VPC.id
  cidr_block              = var.aws_subnet1_AZa
  availability_zone       = var.variable_sub_AZa
  map_public_ip_on_launch = true
  tags = {
    Name = "${local.dev_env}-Subnet1"
  }
}

resource "aws_subnet" "PublicSubnet2" {
  vpc_id                  = aws_vpc.VPC.id
  cidr_block              = var.aws_subnet2_AZb
  availability_zone       = var.variable_sub_AZb
  map_public_ip_on_launch = true
  tags = {
    Name = "${local.dev_env}-Subnet2"
  }
}


resource "aws_security_group" "WS-SG" {
  name   = "allow_HTTPS"
  vpc_id = aws_vpc.VPC.id
  tags = {
    Name = "${local.dev_env}-SG"
  }

}

resource "aws_security_group_rule" "Allow_https" {
  security_group_id = aws_security_group.WS-SG.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}




resource "aws_instance" "WebServer1" {
  ami           = "i-0dd292ae9031ca8c1"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.PublicSubnet1.id
  tags = {
    Name = "${local.dev_env}-WebServer1"
  }
}

resource "aws_instance" "WebServer2" {
  ami           = "i-0dd292ae9031ca8c1"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.PublicSubnet2.id
  tags = {
    Name = "${local.dev_env}-WebServer2"
  }
}

resource "aws_internet_gateway" "IGW" {
  tags = {
    Name = "${local.dev_env}-IGW"
  }
}


resource "aws_internet_gateway_attachment" "IGW_attachment" {
  internet_gateway_id = aws_internet_gateway.IGW.id
  vpc_id              = aws_vpc.VPC.id
}


resource "aws_route_table" "Public_route_table" {
  vpc_id = aws_vpc.VPC.id
  tags = {
    Name = "${local.dev_env}-Main_Route_Table"
  }
}


resource "aws_route" "routea" {
  route_table_id         = aws_route_table.Public_route_table.id
  gateway_id             = aws_internet_gateway.IGW.id
  destination_cidr_block = "0.0.0.0/0"

}


resource "aws_route_table_association" "Subnet1_association" {
  subnet_id      = aws_subnet.PublicSubnet1.id
  route_table_id = aws_route_table.Public_route_table.id
}

resource "aws_route_table_association" "Subnet2_association" {
  subnet_id      = aws_subnet.PublicSubnet2.id
  route_table_id = aws_route_table.Public_route_table.id
}

resource "github_repository" "example" {
  name        = "example"

  visibility = "public"

}
/*





resource "aws_elb" "name" {
  
}

resource "aws_elb_attachment" "name" {
  
}



resource "aws_route" "name" {
  route_table_id = aws_route_table.Public_route_table.id
  
}

resource "aws_route_table_association" "name" {
  
}
*/