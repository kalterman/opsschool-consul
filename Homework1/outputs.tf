output "consul_servers_public_ips" {
    value = module.application.consul_servers_public_ips
    description = "These are the public ip's of the WEB serves"
}

output "app_servers_public_ips" {
    value = module.application.app_servers_public_ips
    description = "These are the private ip's of the DB serves"
}