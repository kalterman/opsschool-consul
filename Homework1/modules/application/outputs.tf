output "consul_servers_public_ips" {
    value = aws_instance.consul-servers.*.public_ip
    description = "These are the public ip's of the consul serves"
}

output "app_servers_public_ips" {
    value = aws_instance.app-servers.*.public_ip
    description = "These are the puclic ip's of the application serves"
}