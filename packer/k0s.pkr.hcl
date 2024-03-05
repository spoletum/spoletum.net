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

source "hcloud" "k0s_arm64" {
  image         = "ubuntu-22.04"
  location      = "fsn1"
  server_type   = var.vm_type
  ssh_username  = "root"
  snapshot_name = "k0s-${var.k0s_version}"
}

build {

  sources = ["source.hcloud.k0s_arm64"]

  provisioner "shell" {
    inline = [
      "curl -sL https://github.com/k0sproject/k0s/releases/download/${var.k0s_version}/k0s-${var.k0s_version}-${var.k0s_arch} -o k0s",
      "install k0s /usr/local/bin/",
      "curl -sL https://get.helm.sh/helm-v3.14.2-linux-${var.k0s_arch}.tar.gz -o helm-v3.14.2-linux-${var.k0s_arch}.tar.gz",
      "tar -zxf helm-v3.14.2-linux-arm64.tar.gz",
      "install linux-${var.k0s_arch}/helm /usr/local/bin/",
      "helm repo add stable https://charts.helm.sh/stable",
      "helm repo add hcloud https://charts.hetzner.cloud",
      "helm repo add argo https://argoproj.github.io/argo-helm",
      "helm repo add camel-k https://apache.github.io/camel-k/charts/",
      "helm repo update",
      "rm -Rf linux-${var.k0s_arch} helm-v3.14.2-linux-arm64.tar.gz k0s"
    ]
  }
}
