data "aws_availability_zones" "available" {
  state = "available"
}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE VPC
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_vpc" "consul-vpc" {
    cidr_block           = var.vpc_cider_block
    enable_dns_support   = "true" 
    enable_dns_hostnames = "true"   
    
    tags = {
        Name = "consul-vpc"
    }
}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE CONSUL SERVERS SUBNETS
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_subnet" "consul-servers-subnets" {
    count                   = length(var.consul_servers_subnets_cidr)
    vpc_id                  = aws_vpc.consul-vpc.id
    cidr_block              = var.consul_servers_subnets_cidr[count.index]
    map_public_ip_on_launch = "true" 
    availability_zone       = data.aws_availability_zones.available.names[count.index]
    tags = {
        Name = "consul-servers-subnet-${count.index+1}"
    }
}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE APPLICATION SERVERS SUBNETS
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_subnet" "app-servers-subnets" {
    count                   = length(var.app_servers_subnets_cidr)
    vpc_id                  = aws_vpc.consul-vpc.id
    cidr_block              = var.app_servers_subnets_cidr[count.index]
    map_public_ip_on_launch = "true" 
    availability_zone       = data.aws_availability_zones.available.names[count.index]
    tags = {
        Name = "app-servers-subnet-${count.index+1}"
    }
}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE INTERNET GATEWAY
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_internet_gateway" "consul-igw" {
    vpc_id = aws_vpc.consul-vpc.id
    tags   = {
        Name = "consul-igw"
    }
}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE PROUTING TABLE
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route_table" "consul-rt" {
    vpc_id = aws_vpc.consul-vpc.id
    route {
        cidr_block = "0.0.0.0/0" 
        gateway_id = aws_internet_gateway.consul-igw.id
    }
    tags = {
        Name = "consul-rt"
    }
}

resource "aws_route_table_association" "consul-servers-rt-subnet"{
    count          = length(aws_subnet.consul-servers-subnets)
    subnet_id      = aws_subnet.consul-servers-subnets[count.index].id
    route_table_id = aws_route_table.consul-rt.id
}

resource "aws_route_table_association" "app-servers-rt-subnet"{
    count          = length(aws_subnet.app-servers-subnets)
    subnet_id      = aws_subnet.app-servers-subnets[count.index].id
    route_table_id = aws_route_table.consul-rt.id
}