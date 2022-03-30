variable "hcloud_token" {
  description = "Hetzner Cloud API Token."
}

variable "ssh_public_key" {
  description = "SSH public key to add to hashi cluster nodes."
  type    = string
}

variable "consul_secret_key" {
  description = "Secret key for encryption of Consul network traffic."
  type    = string
}

variable "cluster_name" {
  description = "Name of the cluster."
  default = "hashi-cluster"
}

variable "snapshot_name" {
  description = "The Packer snapshot name to deploy with."
}

variable "location" {
  description = "The Hetzner Cloud location to deploy to. Defaults to ash."
  default     = "ash"
}

variable "server_type" {
  description = "The server type to use. Defaults to cxp11."
  default     = "cxp11"
}

variable "network_zone" {
  description = "The network zone for internal subnet. Defaults to us-east"
  default     = "us-east"
}
