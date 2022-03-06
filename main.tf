terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.3.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = "XXXXXXXXXXXXXXXX"
  secret_key = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
}

resource "aws_vpc" "main" {
  cidr_block       = var.cidr
  instance_tenancy = "default"

  tags = {
    Name = var.tags
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.tags
  }
}

resource "aws_subnet" "public1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/20"

  tags = {
    Name = var.tags
  }
}

resource "aws_subnet" "public2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.16.0/20"

  tags = {
    Name = var.tags
  }
}

resource "aws_subnet" "private1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.128.0/20"

  tags = {
    Name = var.tags
  }
}

resource "aws_subnet" "private2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.144.0/20"

  tags = {
    Name = var.tags
  }
}

resource "aws_security_group" "my_sg" {
  name        = "my_sg"
  description = "Allow SSH and HTTP inbound traffic"

  ingress {
    description = "SSH into VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "key_tf" {
  key_name = "key_tf"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDXgCRW6PY//P4MML7C+JWlbdOKeQF/QXJRe9qgiW8lEBzGRxbbYq0+ez/80cfDi4HxNvNOqXoVopzRHMIaaddjnsVL/MVik4q0MTTlnsYugU5Z/PB1i78CfQYxuxwB+Y5yzLxVx/jqwvk0zJJfI9PV7JvWxme0CmtWGjz7pQBrlqXtRYvEYrzPkyWXjU6qjGdyNrDZrf5RQckiGeLtc5+JUV6WoHqxznFfyOj1BczDvcOCUpu6AkFwl+WmHGU7hLwDjsVjRMRj/uM0DQI5PZ0mxbe7jZiH7SlwRM1V0sGdCXqWLrBYz77GywXa8XR2QGZOgkP2of8jNOX8CY8+PPDz ec2-user@ip-172-31-80-75.ec2.internal"
}

resource "aws_instance" "myec2" {
    ami = "ami-04505e74c0741db8d"
    key_name = "key_tf"
    instance_type = var.instance_type
    vpc_security_group_ids  = [aws_security_group.my_sg.id]
    user_data = <<-EOF
  #!/bin/sh
  sudo apt-get update
  sudo apt-get install -y apache2
  sudo systemctl status apache2
  sudo systemctl start apache2
  sudo systemctl enable apache2
  echo "Hello GFT, Terraform challenge is done" | sudo tee /var/www/html/index.html
  EOF
    tags = {
        Name = var.tags
    
    }
} 

resource "aws_elb" "myelb" {
  name               = "terraform-elb"
  availability_zones = ["us-east-1a", "us-east-1b"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  instances                   = [aws_instance.myec2.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = var.tags
  }
}

#resource "aws_placement_group" "test" {
#  name     = "test"
 /*  strategy = "cluster"
}

resource "aws_autoscaling_group" "asg_1" {
  name                      = "asg_1"
  max_size                  = 5
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 4
  force_delete              = true
  placement_group           = aws_placement_group.test.id
  launch_configuration      = aws_launch_configuration.as_conf.name
  vpc_zone_identifier       = [aws_subnet.private1.id]
}
resource "aws_autoscaling_group" "asg_2" {
  name                      = "asg_2"
  max_size                  = 5
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 4
  force_delete              = true
  placement_group           = aws_placement_group.test.id
  launch_configuration      = aws_launch_configuration.as_conf.name
  vpc_zone_identifier       = [aws_subnet.private2.id]

}
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_launch_configuration" "as_conf" {
  name          = "web_config"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
 user_data = file("userdata.tpl")
} */
#