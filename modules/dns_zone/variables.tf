variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "project_name" {
  type = string
}

variable "instance_count" {
  type = string
}

variable "dns_zone" {
  type = string
}

variable "combined_vars" {
  type = map(string)
}
