output "vpc-id" {
  value = aws_vpc.consul-vpc.id
  description = "This is the id of the VPC"
}

output "consul-servers-subnets" {
    value = aws_subnet.consul-servers-subnets
    description = "This is a list of the consul servers subnets"
}

output "app-servers-subnets" {
    value = aws_subnet.app-servers-subnets
    description = "This is a list of the application servers subnets"
}