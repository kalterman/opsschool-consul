variable "instance_type" {
    description = "The EC2 instance type to launch"    
    type = string
    default = "t2.micro"
}

variable "key_name" {    
    description = "Name of the keypair to assosiate with the EC2 instances"
    type = string
    default = " "
}

variable "vpc-id" {    
    description = "The id of the VPC"
    type = string
    default = " "
}

variable "consul-servers-subnets" {    
    description = "This is a list of the consul servers subnets"
    type = list
    default = []
}

variable "app-servers-subnets" {    
    description = "This is a list of the application servers subnets"
    type = list
    default = []
}

variable "user-data-consul" {
    description = "This is a shell script to run on the consul servers when they launch"
    type = string
    default = " "
}

variable "user-data-app" {
    description = "This is a shell script to run on the application servers when they launch"
    type = string
    default = " "
}

