terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "1.33.1"
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

data "template_file" "hashi_node_init" {
  template = file("${path.module}/cloud-init/hashi-node.yaml")
  
  vars = {
    username = "hashi-node"
    ssh_public_key = var.ssh_public_key
    consul_secret_key = var.consul_secret_key
  }
}

data "template_file" "hashi_server_init" {
  template = file("${path.module}/cloud-init/hashi-server.yaml")
  
  vars = {
    username = "hashi-node"
    ssh_public_key = var.ssh_public_key
    consul_secret_key = var.consul_secret_key
  }
}

resource "hcloud_server" "hashi-server" {
  name        = "${var.cluster_name}-server"
  server_type = var.server_type

  # Packer image with Consul and Nomad installed
  image       = var.snapshot_name
  location    = var.location

  network {
    network_id = hcloud_network.network.id
    ip         = "10.0.1.1"
  }

  user_data = data.template_file.hashi_server_init.rendered
  placement_group_id = hcloud_placement_group.hashi-cluster.id

  # **Note**: the depends_on is important when directly attaching the
  # server to a network. Otherwise Terraform will attempt to create
  # server and sub-network in parallel. This may result in the server
  # creation failing randomly.
  depends_on = [
    hcloud_network_subnet.network-subnet
  ]
}

resource "hcloud_server" "hashi-node" {
  name        = "${var.cluster_name}-node"
  server_type = var.server_type

  # Packer image with Consul and Nomad installed
  image       = var.snapshot_name
  location    = var.location

  network {
    network_id = hcloud_network.network.id
  }

  user_data = data.template_file.hashi_node_init.rendered

  depends_on = [
    hcloud_network_subnet.network-subnet,
    hcloud_server.hashi-server
  ]
}

