#VPC
resource "aws_vpc" "aws-networking-vpc" {
  cidr_block = "10.0.0.0/16"

   tags = {
    Name = "aws-networking-vpc"
  }
}

#Private subnets
resource "aws_subnet" "private-1" {
  vpc_id     = aws_vpc.aws-networking-vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = false
  availability_zone = "us-east-1a"

  tags = {
    Name = "Private 1"
  }
}

resource "aws_subnet" "private-2" {
  vpc_id     = aws_vpc.aws-networking-vpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = false
  availability_zone = "us-east-1b"

  tags = {
    Name = "Private 2"
  }
}

#Public subnets
resource "aws_subnet" "public-1" {
  vpc_id     = aws_vpc.aws-networking-vpc.id
  cidr_block = "10.0.101.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"

  tags = {
    Name = "Public 1"
  }
}

resource "aws_subnet" "public-2" {
  vpc_id     = aws_vpc.aws-networking-vpc.id
  cidr_block = "10.0.102.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1b"

  tags = {
    Name = "Public 2"
  }
}

#Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.aws-networking-vpc.id
}

#IG Route table
resource "aws_route_table" "igw_route_table" {
  vpc_id = aws_vpc.aws-networking-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "IGW Route-table"
  }
}

#Route table association
resource "aws_route_table_association" "public_rt_1" {
  subnet_id      = aws_subnet.public-1.id
  route_table_id = aws_route_table.igw_route_table.id
}

resource "aws_route_table_association" "public_rt_2" {
  subnet_id      = aws_subnet.public-2.id
  route_table_id = aws_route_table.igw_route_table.id
}

#NAT Gateway for Private subnets
resource "aws_nat_gateway" "nat-1" {
  connectivity_type = "public"
  subnet_id         = aws_subnet.public-1.id
  allocation_id = aws_eip.eip1.id
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat-2" {
  connectivity_type = "public"
  subnet_id         = aws_subnet.public-2.id
  allocation_id = aws_eip.eip2.id
  depends_on = [aws_internet_gateway.igw]
}

#Elastic IP for Nat Gateways
resource "aws_eip" "eip1" {
  domain   = "vpc"
}

resource "aws_eip" "eip2" {
  domain   = "vpc"
}

#Private Route table 1
resource "aws_route_table" "private_route_table1" {
  vpc_id = aws_vpc.aws-networking-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-1.id
  }
  tags = {
    Name = "Private Route-table 1"
  }
}

#Private Route table 2
resource "aws_route_table" "private_route_table2" {
  vpc_id = aws_vpc.aws-networking-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-2.id
  }
  tags = {
    Name = "Private Route-table 2"
  }
}

#Private Route table association
resource "aws_route_table_association" "private_rt_1" {
  subnet_id      = aws_subnet.private-1.id
  route_table_id = aws_route_table.private_route_table1.id
}

resource "aws_route_table_association" "private_rt_2" {
  subnet_id      = aws_subnet.private-2.id
  route_table_id = aws_route_table.private_route_table2.id
}

#ALB Security Group
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.aws-networking-vpc.id

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4_https" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4_http" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

#EC2 Security Group
resource "aws_security_group" "app_sg" {
  vpc_id = aws_vpc.aws-networking-vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
  security_group_id            = aws_security_group.app_sg.id
  referenced_security_group_id = aws_security_group.allow_tls.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

#ALB
resource "aws_lb" "lb" {
  name               = "lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_tls.id]
  subnets            = [  aws_subnet.public-1.id,aws_subnet.public-2.id]
}

#ALB Target Groups
resource "aws_lb_target_group" "alb-target-group" {
  name        = "alb-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.aws-networking-vpc.id
}

#ALB listner
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-target-group.arn
  }
}

# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Launch Template
resource "aws_launch_template" "ec2_template" {
  name_prefix   = "ec2-template-"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"

  vpc_security_group_ids = [
    aws_security_group.app_sg.id
  ]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y nginx
              systemctl start nginx
              systemctl enable nginx
              echo "Hello from Private EC2" > /usr/share/nginx/html/index.html
              EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "app-instance"
    }
  }
}

#Auto-Scaling Groups
resource "aws_autoscaling_group" "asg" {
  name                      = "asg"
  max_size                  = 4
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  vpc_zone_identifier       = [aws_subnet.private-1.id, aws_subnet.private-2.id] 
  target_group_arns         = [aws_lb_target_group.alb-target-group.arn]
  launch_template {
    id      = aws_launch_template.ec2_template.id
    version = "$Latest"
  }
}