provider "aws" {
  region     = "us-east-2"
  access_key = "*********"
  secret_key = "******"

}
#1.create a VPC 
resource "aws_vpc" "production" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "production"
  }

}

#2. subnet 
resource "aws_subnet" "public-subnet-prod" {
  vpc_id            = aws_vpc.production.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-2a"
  tags = {
    Name = "public-subnet-prod"
  }


}

#internet-gateway
resource "aws_internet_gateway" "prod-gateway" {
  vpc_id = aws_vpc.production.id
  tags = {
    "Name" = "prod-gateway"
  }

}

#route table
resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.production.id
  route {
    #ipv4routes
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod-gateway.id
  }
  route {
    #ipv6routes
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_internet_gateway.prod-gateway.id

  }
  tags = {
    Name = "Prod-route-table"
  }
}

#subnet-route-table-assocation 

resource "aws_route_table_association" "prod-assocaition" {

  subnet_id      = aws_subnet.public-subnet-prod.id
  route_table_id = aws_route_table.prod-route-table.id

}
#security-group allowing port 22, 80, 443

resource "aws_security_group" "allow_web_traffic" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.production.id

  ingress = [
    {
      description      = "HTTPS"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    },
    {
      description      = "HTTP"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    },
    {
      description      = "SSH"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  ]



  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  ]

  tags = {
    Name = "allow_web_traffic"
  }
}

#network interface with an ip in the subnet create above
resource "aws_network_interface" "prod-web-interface" {
  subnet_id = aws_subnet.public-subnet-prod.id

  private_ip      = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web_traffic.id]

}
#Elastic IP address assignment to the above interface
resource "aws_eip" "elastic_ip_prod" {
  vpc                       = true
  network_interface         = aws_network_interface.prod-web-interface.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [
    aws_internet_gateway.prod-gateway
  ]
}

#ubuntu instance -> web server

