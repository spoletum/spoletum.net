output "inventory" {
  value = templatefile("${path.module}/templates/inventory.tpl", {
    ansible_user    = var.ANSIBLE_USER
    bastion_ip_addr = hcloud_server.albornoz.ipv4_address
    controlplane    = [for server in hcloud_server.controlplane : { name = server.name, ip4_address = server.network[*].ip }]
  })
  sensitive = true
}

# output "debug" {
#   value = [for server in hcloud_server.controlplane : { name = server.name, ip4_address = server.network[*].ip }]
# }
