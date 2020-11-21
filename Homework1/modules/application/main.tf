# ----------------------------------------------------------------------------------------------------------------------
# CREATE IAM INSTANCE PROFILE FOR CONSUL INSTANCES  
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "consul_role" {
  name = "consul_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "consul_profile" {
  name = "consul_profile"
  role = aws_iam_role.consul_role.name
}

resource "aws_iam_role_policy" "consul_policy" {
  name = "consul_policy"
  role = aws_iam_role.consul_role.id

  policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
     {
     "Sid": "",
     "Effect": "Allow",
     "Action": "ec2:DescribeInstances",
     "Resource": "*"
     }  
 ]
 }
EOF
}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE SECURITY GROUP FOR CONSUL SERVERS
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "consul-sg" {
  name   = "consul-sg"
  vpc_id = var.vpc-id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow all inside security group"
  }
  
  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow consul UI access from the world"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow ssh from the world"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outside traffic"
  }

  tags = {
        Name = "consul-sg"
    }
}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE SECURITY GROUP FOR APPLICATION SERVERS
# ----------------------------------------------------------------------------------------------------------------------
# create security group for application server
resource "aws_security_group" "app-sg" {
  name   = "app-sg"
  vpc_id = var.vpc-id

  # for HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # for SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
        Name = "app-sg"
    }
}

# ----------------------------------------------------------------------------------------------------------------------
# SEARCH FOR UBUNTU 18.04 RECENT AMI ID
# ----------------------------------------------------------------------------------------------------------------------
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE CONSUL SERVERS    
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_instance" "consul-servers" {
  count                       = length(var.consul-servers-subnets)
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  iam_instance_profile        = aws_iam_instance_profile.consul_profile.name
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.consul-sg.id]
  associate_public_ip_address = "true"
  subnet_id                   = var.consul-servers-subnets[count.index].id
  user_data                   = var.user-data-consul

  root_block_device {
      delete_on_termination = true
      volume_size           = "8"
      volume_type           = "standard"
    }

  tags = {
    Name    = "consul-server-${count.index+1}"
    Owner   = "Karen"
    Consul  = "Server"
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE APPLICATION SERVERS    
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_instance" "app-servers" {
  count                       = length(var.app-servers-subnets)
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  iam_instance_profile        = aws_iam_instance_profile.consul_profile.name
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.app-sg.id,aws_security_group.consul-sg.id]
  associate_public_ip_address = "true"
  subnet_id                   = var.app-servers-subnets[count.index].id
  user_data                   = var.user-data-app

  root_block_device {
      delete_on_termination = true
      volume_size           = "8"
      volume_type           = "standard"
    }

  tags = {
    Name    = "app-server-${count.index+1}"
    Owner   = "Karen"
    Consul  = "Client"
  }
}