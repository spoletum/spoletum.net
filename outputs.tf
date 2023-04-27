locals {
  ansible_inventory = templatefile("${path.module}/templates/inventory.tpl",
    {
      albornoz = hcloud_server.albornoz.ipv4_address
    }
  )
}

output "ansible_inventory" {
  value = local.ansible_inventory
}
