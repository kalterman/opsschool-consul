variable "vpc_cider_block" {
    description = "The cider of the VPC"
    type = string
    default = "10.0.0.0/16"
}

variable "consul_servers_subnets_cidr" {
    description = "The ciders of the consul servers subnets"
    type = list
    default = []
}

variable "app_servers_subnets_cidr" {
    description = "The ciders of the application servers subnets"
    type = list
    default = []
}