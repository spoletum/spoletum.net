packer {
  required_plugins {
    hcloud = {
      source  = "github.com/hetznercloud/hcloud"
      version = "1.3.0"
    }
  }
}

variable "k0s_version" {
  type    = string
  default = "v1.29.2+k0s.0"
}

variable "k0s_arch" {
  type    = string
  default = "arm64"
}

variable "vm_type" {
  type    = string
  default = "cax11"
}

source "hcloud" "k0s_controller_arm64" {
  image         = "ubuntu-22.04"
  location      = "fsn1"
  server_type   = var.vm_type
  ssh_username  = "root"
  snapshot_name = "k0s-controller-${var.k0s_version}"
}

build {

  sources = ["source.hcloud.k0s_controller_arm64"]

  provisioner "shell" {
    inline = [
      "curl -sL https://github.com/k0sproject/k0s/releases/download/${var.k0s_version}/k0s-${var.k0s_version}-${var.k0s_arch} -o k0s",
      "sudo install k0s /usr/local/bin/",
      "sudo k0s install controller --single",
      "sudo systemctl enable k0scontroller"
    ]
  }
}
