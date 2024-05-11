variable "host" {
  type = string
}

variable "client_certificate" {
  type = string
}

variable "client_key" {
  type = string
}

variable "cluster_ca_certificate" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "public_ip_resource_group" {
  type = string
}

variable "public_ip_name" {
  type = string
}
variable "public_ip_dns" {
  type = string
}

variable "k8s_combined_vars" {
  type = map(string)
}

variable "k8s_depends_on" {
  # the value doesn't matter; we're just using this variable
  # to propagate dependencies.
  type    = any
  default = []
}
