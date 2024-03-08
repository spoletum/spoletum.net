resource "hcloud_network" "development" {
  name     = "external"
  ip_range = "10.0.0.0/24"
}

resource "hcloud_network_subnet" "internal" {
  for_each     = toset(var.subnets)
  ip_range     = each.value.ip_range
  network_zone = each.network_zone
  network_id   = hcloud_network.development.id
  type         = each.type
}
