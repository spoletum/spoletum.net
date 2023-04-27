terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
  }
  cloud {
    organization = "spoletum-net"
    workspaces {
      name = "spoletum-net"
    }
  }
}

variable "hcloud_token" {
  sensitive = true
}

variable "ssh_public_key" {}

variable "ansible_public_key" {}

# Configure the Hetzner Cloud Provider
provider "hcloud" {}

resource "hcloud_ssh_key" "personal" {
  name       = "personal"
  public_key = var.ssh_public_key
}

resource "hcloud_network" "petclinic" {
  name     = "petclinic"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "infra" {
  network_id   = hcloud_network.petclinic.id
  network_zone = "eu-central"
  type         = "cloud"
  ip_range     = "10.0.0.0/24"
}

resource "hcloud_server_network" "name" {
  network_id = hcloud_network_subnet.infra.network_id
  server_id  = hcloud_server.petclinic.id
}

resource "hcloud_server" "petclinic" {
  name        = "petclinic"
  server_type = "cax31"
  image       = "fedora-37"
  datacenter  = "fsn1-dc14"
  network {
    network_id = hcloud_network.petclinic.id
  }
  ssh_keys = [hcloud_ssh_key.personal.name]
  # user_data = base64encode(templatefile("${path.module}/cloud-init.tpl", {
  #   ansible_public_key = var.ansible_public_key,
  # }))
}

# resource "local_file" "inventory" {
#   content = templatefile("${path.module}/inventory.tpl",
#     {
#       dev01         = hcloud_server.petclinic.ipv4_address
#       dev01_private = tolist(hcloud_server.petclinic.network)[0].ip
#     }
#   )
#   filename = "../ansible/inventory.ini"
# }

resource "hcloud_rdns" "petclinic" {
  dns_ptr    = "spoletum.net"
  ip_address = hcloud_server.petclinic.ipv4_address
  server_id  = hcloud_server.petclinic.id
}
