terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-west-2a"
  tags = {
    Name = "Public"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-2b"
  tags = {
    Name = "Private"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

 route {
    cidr_block = "0.0.0.0/0"
    network_interface_id = aws_instance.instance-aws-net.primary_network_interface_id
  }

  tags = {
    Name = "Private Route Table"
  }
}

resource "aws_main_route_table_association" "a" {
 vpc_id = aws_vpc.vpc.id
  route_table_id = aws_route_table.private.id
}


resource "aws_route_table_association" "to-subnet" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "to-private-subnet" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}


resource "aws_instance" "instance-public-subnet" {
  subnet_id     = aws_subnet.public.id
  ami           = "ami-00ee4df451840fa9d"
  key_name      = "aws"
  instance_type = "t2.micro"
  
  depends_on = [aws_internet_gateway.gw]

  user_data = <<EOF
      sudo su
      yum update –y
      yum install httpd –y
      service httpd start
      chkconfig httpd on
      cd /var/www/html
      echo "<html><h1>This is WebServer from public subnet</h1></html>" > index.html 
      
   EOF           
}

resource "aws_instance" "instance-private-subnet" {
  subnet_id     = aws_subnet.private.id
  ami           = "ami-00ee4df451840fa9d"
  key_name      = "aws"
  instance_type = "t2.micro"
  #depends_on = [aws_internet_gateway.gw]

  user_data = <<EOF
      sudo su
      yum update –y
      yum install httpd –y
      service httpd start
      chkconfig httpd on
      cd /var/www/html
      echo "<html><h1>This is WebServer from private subnet</h1></html>" > index.html
    EOF
  
}

resource "aws_instance" "instance-aws-net" {
  subnet_id     = aws_subnet.public.id
  ami           = "ami-0032ea5ae08aa27a2"
  key_name      = "aws"
  instance_type = "t2.micro"
  source_dest_check = false
}

resource "aws_network_interface_sg_attachment" "sg_attachment_aws_net" {
  security_group_id    = aws_security_group.public.id
  network_interface_id = aws_instance.instance-aws-net.primary_network_interface_id
}

resource "aws_network_interface_sg_attachment" "sg_attachment_public" {
  security_group_id    = aws_security_group.public.id
  network_interface_id = aws_instance.instance-public-subnet.primary_network_interface_id
}

resource "aws_network_interface_sg_attachment" "sg_attachment_private" {
  security_group_id    = aws_security_group.private.id
  network_interface_id = aws_instance.instance-private-subnet.primary_network_interface_id
}

resource "aws_security_group" "public" {
  name = "cloudcasts-public-sg"
  description = "Public internet access"
  vpc_id = aws_vpc.vpc.id 
}

resource "aws_security_group_rule" "public_out" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public.id
}

resource "aws_security_group_rule" "public_in_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public.id
}
 
resource "aws_security_group_rule" "public_in_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public.id
}
 
resource "aws_security_group_rule" "public_in_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public.id
}

resource "aws_security_group" "private" {
  name = "cloudcasts-private-sg"
  description = "private internet access"
  vpc_id = aws_vpc.vpc.id 
}

resource "aws_security_group_rule" "private_out" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.private.id
}

resource "aws_security_group_rule" "private_in_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["10.0.1.0/24"]
  security_group_id = aws_security_group.private.id
}
 
resource "aws_security_group_rule" "private_in_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["10.0.1.0/24"]
  security_group_id = aws_security_group.private.id
}

resource "aws_security_group_rule" "private_in_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["10.0.1.0/24"]
  security_group_id = aws_security_group.private.id
}
 
resource "aws_security_group_rule" "private_in_icmp" {
  type              = "ingress"
  from_port         = 8
  to_port           = 0
  protocol          = "icmp"
  cidr_blocks       = ["10.0.1.0/24"]
  security_group_id = aws_security_group.private.id
}

resource "aws_lb_target_group" "tg-loadbalancer" {
  name = "loadbalancer"
  vpc_id   = aws_vpc.vpc.id
  port = 80
  protocol = "HTTP"
}

resource "aws_lb" "lb" {
  name               = "lb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public.id]
  subnets            = [aws_subnet.public.id, aws_subnet.private.id]

  tags = {
    Environment = "dev"
  }
}

resource "aws_lb_target_group_attachment" "a" {
  target_group_arn = aws_lb_target_group.tg-loadbalancer.arn
  target_id        = aws_instance.instance-private-subnet.id
}

resource "aws_lb_target_group_attachment" "b" {
  target_group_arn = aws_lb_target_group.tg-loadbalancer.arn
  target_id        = aws_instance.instance-public-subnet.id
}

resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-loadbalancer.arn
  }
}