terraform {

  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
    hetznerdns = {
      source = "timohirt/hetznerdns"
    }
  }

  cloud {
    organization = "spoletum"
    workspaces {
      name = "spoletum-net"
    }
  }
}

# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = var.HCLOUD_TOKEN
}

provider "hetznerdns" {
  apitoken = var.HDNS_TOKEN
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

# Zone is created manually as there is some work with Google Domains that needs to be done
data "hetznerdns_zone" "spoletum_net" {
  name = "spoletum.net"
}

resource "hetznerdns_record" "example_com_root" {
  zone_id = data.hetznerdns_zone.spoletum_net.id
  name    = "albornoz"
  value   = hcloud_server.albornoz.ipv4_address
  type    = "A"
}
