locals {
  vm_name = "${var.os_version}-${var.arch}"
}

variable "iso_url" {
  type    = string
  default = "https://cdimage.ubuntu.com/releases/noble/release/ubuntu-24.04.1-live-server-arm64.iso"
}

variable "iso_checksum" {
  type    = string
  default = "sha256:5ceecb7ef5f976e8ab3fffee7871518c8e9927ec221a3bb548ee1193989e1773"
}

variable "os_version" {
  type    = string
  default = "ubuntu-24-04"
}

variable "arch" {
  type    = string
  default = "arm64"
}

variable "memory" {
  type    = number
  default = 2048
}

variable "disk_size" {
  type = number
  default = 20000
}

variable "hcp_client_id" {
  type    = string
  default = "${env("HCP_CLIENT_ID")}"
}

variable "hcp_client_secret" {
  type    = string
  default = "${env("HCP_CLIENT_SECRET")}"
}