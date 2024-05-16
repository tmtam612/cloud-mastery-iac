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

variable "backend_storge_account_name" {
  type = string
}

variable "backend_container_name" {
  type = string
}

variable "backend_blob_name" {
  type = string
}

variable "backend_secret_name" {
  type = string
}

variable "backend_secret_namespace" {
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
