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
  name   = "allow_HTTP_ssh"
  vpc_id = aws_vpc.VPC.id
  tags = {
    Name = "${local.dev_env}-SG"
  }

}

resource "aws_security_group_rule" "Allow_http_inbound" {
  security_group_id = aws_security_group.WS-SG.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "Allow_ssh_inbound" {
  security_group_id = aws_security_group.WS-SG.id
  type = "ingress"
  to_port = 22
  from_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "Allow_all_outbound" {
  security_group_id = aws_security_group.WS-SG.id
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = -1
  cidr_blocks = ["0.0.0.0/0"
  ]

}

resource "aws_key_pair" "PR1_KP" {
  key_name   = "Webserver-KP"
  public_key = file("~/.ssh/id_rsa.pub")
    tags = {
    Name = "${local.dev_env}-KP"
}
}

resource "aws_instance" "WebServer1" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id = aws_subnet.PublicSubnet1.id
  key_name = aws_key_pair.PR1_KP.key_name
  vpc_security_group_ids = [ aws_security_group.WS-SG.id ]
  tags = {
    Name = "${local.dev_env}-WebServer1"
  }

  user_data = <<-EOL
  #!/bin/bash -xe

  sudo yum update -y
  sudo yum install httpd -y
  sudo systemctl start httpd
  sudo systemctl enable httpd
  echo "This is Web Server 1" | sudo tee /var/www/html/index.html
  EOL
}

resource "aws_instance" "WebServer2" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id = aws_subnet.PublicSubnet2.id
  key_name = aws_key_pair.PR1_KP.key_name
  vpc_security_group_ids = [ aws_security_group.WS-SG.id ]
  tags = {
    Name = "${local.dev_env}-WebServer2"
  }

  user_data = <<-EOL
  #!/bin/bash -xe

  sudo yum update -y
  sudo yum install httpd -y
  sudo systemctl start httpd
  sudo systemctl enable httpd
  echo "This is Web Server 2" | sudo tee /var/www/html/index.html
  EOL
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


resource "aws_alb" "PR1_alb" {
  name               = "ProjectLB"
  load_balancer_type = "application"
  internal           = false
  security_groups = [ aws_security_group.WS-SG.id ]

  subnet_mapping {
    subnet_id = aws_subnet.PublicSubnet1.id
  }

  subnet_mapping {
    subnet_id = aws_subnet.PublicSubnet2.id
  }
    tags = {
    Name = "${local.dev_env}-ALB"
    }
}

resource "aws_lb_target_group" "TG" {
  name     = "ProjectTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.VPC.id
  health_check {
    path = "/"
    port = "traffic-port"
}
  tags = {
    Name = "${local.dev_env}-TG"
  }
}

resource "aws_lb_target_group_attachment" "TGA1" {
  target_group_arn = aws_lb_target_group.TG.arn
  target_id = aws_instance.WebServer1.id
  port = 80
}

resource "aws_lb_target_group_attachment" "TGA2" {
  target_group_arn = aws_lb_target_group.TG.arn
  target_id = aws_instance.WebServer2.id
  port = 80
}

resource "aws_lb_listener" "Web" {
  load_balancer_arn = aws_alb.PR1_alb.arn
  port              = "80"
  protocol          = "HTTP"


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TG.arn

  }
}

output "LoadBalancerDNS" {
  value = aws_alb.PR1_alb.dns_name
}