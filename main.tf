terraform {

  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
  }

  cloud {
    organization = "spoletum"
    workspaces {
      name = "spoletum-net"
    }
  }
}

variable "HCLOUD_TOKEN" {
  sensitive = true
}

variable "SSH_PUBLIC_KEY" {
  sensitive = true
}

variable "ANSIBLE_PUBLIC_KEY" {
  sensitive = true
}

# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = var.HCLOUD_TOKEN
}

resource "hcloud_ssh_key" "personal" {
  name       = "personal"
  public_key = var.SSH_PUBLIC_KEY
}

resource "hcloud_network" "albornoz" {
  name     = "albornoz"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "infra" {
  network_id   = hcloud_network.albornoz.id
  network_zone = "eu-central"
  type         = "cloud"
  ip_range     = "10.0.0.0/24"
}

resource "hcloud_server_network" "name" {
  network_id = hcloud_network_subnet.infra.network_id
  server_id  = hcloud_server.albornoz.id
}

resource "hcloud_server" "albornoz" {
  name        = "albornoz"
  server_type = "cax31"
  image       = "fedora-37"
  datacenter  = "fsn1-dc14"
  network {
    network_id = hcloud_network.albornoz.id
  }
  ssh_keys = [hcloud_ssh_key.personal.name]
  user_data = base64encode(templatefile("${path.module}/templates/cloud-init.tpl", {
    ansible_public_key = var.ANSIBLE_PUBLIC_KEY,
  }))
}

# resource "local_file" "inventory" {
#   content = templatefile("${path.module}/inventory.tpl",
#     {
#       dev01         = hcloud_server.albornoz.ipv4_address
#       dev01_private = tolist(hcloud_server.albornoz.network)[0].ip
#     }
#   )
#   filename = "../ansible/inventory.ini"
# }

resource "hcloud_rdns" "albornoz" {
  dns_ptr    = "spoletum.net"
  ip_address = hcloud_server.albornoz.ipv4_address
  server_id  = hcloud_server.albornoz.id
}
