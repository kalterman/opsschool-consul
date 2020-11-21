locals {
  nginx = <<USERDATA
#!/bin/bash
set -e

echo "Installing dependencies..."
apt-get -y update
apt-get -y install nginx
apt-get -y install dnsmasq

echo "<h1>I am a consul agent!</h1>" > /var/www/html/index.nginx-debian.html

echo "Configuring dnsmasq..."
echo "server=/consul/127.0.0.1#8600" > /etc/dnsmasq.d/10-consul
systemctl restart dnsmasq

echo 'DNS=127.0.0.1
Domains=~consul' >> /etc/systemd/resolved.conf
systemctl restart systemd-resolved.service

echo "Installing consul..."
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install consul

echo "Configure consul client config file..."
echo '{
        "data_dir": "/opt/consul",
        "datacenter": "karen-dc",
        "encrypt": "OORn8bDKeMcKJT2bR/eBGOvISOkp+MHAdlnfxzIVQNQ=",
        "disable_remote_exec": true,
        "disable_update_check": true,
        "leave_on_terminate": true,
        "retry_join": ["provider=aws tag_key=Consul tag_value=Server"],
        "enable_script_checks": true,
        "server": false
     }' > /etc/consul.d/config.json

echo '{
  "service": {
    "name": "webserver",
    "tags": [
      "nginx"
    ],
    "port": 80,
    "check": {
      "id": "webserver_check",
      "name": "Check nginx webserver",
      "http": "http://localhost:80",
      "method": "GET",
      "interval": "10s",
      "timeout": "1s"
    }
  }
}' > /etc/consul.d/webserver.json

echo "Starting consul agent..."
consul agent -config-dir=/etc/consul.d
USERDATA
}

locals {
  consul = <<USERDATA
#!/bin/bash
set -e

echo "Installing dependencies..."
apt-get -y update
apt-get -y install dnsmasq

echo "Configuring dnsmasq..."
echo "server=/consul/127.0.0.1#8600" > /etc/dnsmasq.d/10-consul
systemctl restart dnsmasq

echo 'DNS=127.0.0.1
Domains=~consul' >> /etc/systemd/resolved.conf
systemctl restart systemd-resolved.service

echo "Installing consul..."
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install consul

echo "Configure consul server config file..."
echo '{
        "data_dir": "/opt/consul",
        "datacenter": "karen-dc",
        "encrypt": "OORn8bDKeMcKJT2bR/eBGOvISOkp+MHAdlnfxzIVQNQ=",
        "disable_remote_exec": true,
        "disable_update_check": true,
        "leave_on_terminate": true,
        "retry_join": ["provider=aws tag_key=Consul tag_value=Server"],
        "server": true,
        "bootstrap_expect": 3,
        "ui": true,
        "client_addr": "0.0.0.0"
}' > /etc/consul.d/config.json

echo "Starting consul agent..."
consul agent -config-dir=/etc/consul.d
USERDATA
}