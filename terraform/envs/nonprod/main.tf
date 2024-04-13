terraform {

  backend "s3" {
    bucket = "spoletum-net-terraform"
    region = "eu-south-2"
    key    = "pilum"
  }

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.45.0"
    }
  }
}

resource "hcloud_ssh_key" "default" {
  name       = "pilum"
  public_key = var.ssh_public_key
}

resource "hcloud_placement_group" "default" {
  name = "default"
  type = "spread"
}

resource "hcloud_server" "pilum" {
  name               = "development"
  image              = var.image_id
  server_type        = var.server_type
  ssh_keys           = [hcloud_ssh_key.default.id]
  placement_group_id = hcloud_placement_group.default.id
  user_data = templatefile("${path.module}/${var.cloud_init_file}", {
    ssh_public_key = var.ssh_public_key
  })
}

resource "hcloud_rdns" "pilum" {
  server_id  = hcloud_server.pilum.id
  ip_address = hcloud_server.pilum.ipv4_address
  dns_ptr    = "spoletum.net"
}