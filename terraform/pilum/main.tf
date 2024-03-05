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

resource "hcloud_network" "public" {
  name     = "public"
  ip_range = "10.0.0.0/24"
}

resource "hcloud_placement_group" "default" {
  name = "default"
  type = "spread"
}

resource "hcloud_server" "pilum" {
  name               = "k0s-controller"
  image              = var.image_id
  server_type        = "cax41"
  ssh_keys           = [hcloud_ssh_key.default.id]
  placement_group_id = hcloud_placement_group.default.id
}