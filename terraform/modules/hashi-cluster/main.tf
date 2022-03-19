terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "1.26.0"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

# Hashi Nomad/Consul nodes

resource "hcloud_placement_group" "hashi-cluster" {
  name = var.cluster_name
  type = "spread"
}

data "template_file" "init-hashi-cluster" {
  template = file("./cloud-init/init-hashi-cluster.yaml")

  vars {
    username = "hashi-node"
    ssh_public_key = var.ssh_public_key
    consul_secret_key = var.consul_secret_key
  }
}

resource "hcloud_server" "hashi-node" {
  name        = "${vars.cluster_name}-node"
  server_type = var.hcloud_server_type

  # Packer image with Consul and Nomad installed
  image       = var.snapshot_name
  location    = var.hcloud_location

  network {
    network_id = hcloud_network.network.id
    ip         = "10.0.1.1"
  }

  user_data = data.template_file.init-hashi-cluster.rendered
  placement_group_id = hcloud_placement_group.hashi-cluster.id

  # **Note**: the depends_on is important when directly attaching the
  # server to a network. Otherwise Terraform will attempt to create
  # server and sub-network in parallel. This may result in the server
  # creation failing randomly.
  depends_on = [
    hcloud_network_subnet.network-subnet
  ]
}
