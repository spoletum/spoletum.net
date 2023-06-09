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

# Albornoz is the jump host for system management
resource "hcloud_server" "albornoz" {
  name        = "albornoz"
  server_type = "cax31"
  image       = "fedora-37"
  datacenter  = "fsn1-dc14"
  network {
    network_id = hcloud_network.albornoz.id
    alias_ips  = [] # https://github.com/hetznercloud/terraform-provider-hcloud/issues/650
  }
  ssh_keys = [hcloud_ssh_key.personal.name]
  user_data = base64encode(templatefile("${path.module}/templates/cloud-init.tpl", {
    ansible_user       = var.ANSIBLE_USER
    ansible_public_key = var.ANSIBLE_PUBLIC_KEY,
  }))
}

# The control plane nodes will contain Vault, Consul, and the Nomad Server
resource "hcloud_server" "controlplane" {
  count       = 1
  name        = "controlplane-${format("%02d", count.index)}"
  server_type = "cax31"
  image       = "fedora-37"
  datacenter  = "fsn1-dc14"
  network {
    network_id = hcloud_network.albornoz.id
    alias_ips  = [] # https://github.com/hetznercloud/terraform-provider-hcloud/issues/650
  }
  ssh_keys = [hcloud_ssh_key.personal.name]
  user_data = base64encode(templatefile("${path.module}/templates/cloud-init.tpl", {
    ansible_user       = var.ANSIBLE_USER
    ansible_public_key = var.ANSIBLE_PUBLIC_KEY,
  }))
  public_net {
    ipv4_enabled = false
    ipv6_enabled = false
  }
}

# The control plane nodes will contain Vault, Consul, and the Nomad Server
resource "hcloud_server" "worker" {
  count       = 3
  name        = "worker-${format("%02d", count.index)}"
  server_type = "cax31"
  image       = "fedora-37"
  datacenter  = "fsn1-dc14"
  network {
    network_id = hcloud_network.albornoz.id
    alias_ips  = [] # https://github.com/hetznercloud/terraform-provider-hcloud/issues/650
  }
  ssh_keys = [hcloud_ssh_key.personal.name]
  user_data = base64encode(templatefile("${path.module}/templates/cloud-init.tpl", {
    ansible_user       = var.ANSIBLE_USER
    ansible_public_key = var.ANSIBLE_PUBLIC_KEY,
  }))
  public_net {
    ipv4_enabled = false
    ipv6_enabled = false
  }
}

# Zone is created manually as there is some work with Google Domains that needs to be done
data "hetznerdns_zone" "spoletum_net" {
  name = "spoletum.net"
}

resource "hetznerdns_record" "albornoz" {
  zone_id = data.hetznerdns_zone.spoletum_net.id
  name    = "albornoz"
  value   = hcloud_server.albornoz.ipv4_address
  type    = "A"
}
