# Set the variable value in *.tfvars file
# or using the -var="hcloud_token=..." CLI option
variable "hcloud_token" {}
variable "consul_secret_key" {}

variable "ssh_pub_key" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}

module "hashi_cluster" {
  source = "./modules/hashi-cluster"

  hcloud_token = var.hcloud_token
  ssh_public_key = file(var.ssh_pub_key)
  consul_secret_key = var.consul_secret_key
  cluster_name = "hashi-cluster"
  snapshot_name = "64444702"
  location = "ash"
  server_type = "cpx11"
}

