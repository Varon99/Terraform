provider "aws" {
  region = "us-west-2"

 access_key = "AKIA5I7RQP5YEXYVBJ2G"
 secret_key = "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"
  }

  #create a vpc
  resource "aws_vpc" "prod-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "production"
  }
}
  #create an internet gateway
  resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.prod-vpc.id
  }

  #create Custom Route Table
  resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Prod"
  }
}

#create a Subnet

  resource "aws_subnet" "subnet-1" {
    vpc_id = aws_vpc.prod-vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-west-2a"

    tags = {
        Name = "prod-subnet"
    }
  }

  #Associate subnet with Route Table
  resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.prod-route-table.id
}

 #Create Security Group to allow port 22,80,44
 resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.prod-vpc.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   
  }
ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
ingress {
    description      = "HTTP"
    from_port        = 00
    to_port          = 00
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
ingress {
    description      = "SSH"
    from_port        = 2
    to_port          = 2
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_web"
  }
}
#create a network interface with an IP in the subnet that was created in step 4

resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]
}
  #Assign an elastic IP to the network interface created in the step above
  
resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.gw]
}
#Create Windows server and install/enable apache2
resource "aws_instance" "web-server-instance" {
  ami= "ami-0d70546e43a941d70"
  instance_type = "t2.micro"
  availability_zone = "us-west-2a"
  key_name = "main-key"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.web-server-nic.id
  }
  user_data = <<-EOF
              #l/bin/trash
              sudo apt update -y
              sudo apt install apache2 -y
              sudo systemct1 start apache2
              sudo bash -c 'echo your very first web server > /var/www/html/index.html'
              EOF
            tags = {
                Name = "web-server"
              }
            }


#resource "aws_vpc" "first-vpc" {
 # cidr_block = "10.0.0.0/16"
  #tags = {
   # Name = "production"
  #}
#}

#resource "aws_subnet" "subnet-1" {
 # vpc_id     = aws_vpc.first-vpc.id
  #cidr_block = "10.0.1.0/24"

  #tags = {
   # Name = "prod-subnet"
  #}
#}

#resource "aws_vpc" "second-vpc" {
 # cidr_block = "10.1.0.0/16"
  #tags = {
   # Name = "Dev"
  #}
#}

#resource "aws_subnet" "subnet-2" {
 # vpc_id     = aws_vpc.second-vpc.id
  #cidr_block = "10.0.0.0/24"

  #tags = {
   # Name = "Dev-subnet"
  #}
#}

  #resource "<provider>_<resource_type>" "name" {
   # config options_____
   # key = "value"
    #key2 = "another value"
  #}
