resource "hcloud_network" "development" {
  name     = "external"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "internal" {
  for_each     = var.subnets
  ip_range     = each.value.value.ip_range
  network_zone = each.value.zone
  network_id   = hcloud_network.development.id
  type         = each.value.type
}
