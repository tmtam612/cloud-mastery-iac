variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "location" {
  type = string
}

variable "instance_count" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "combined_vars" {
  type = map(string)
}

variable "list_subnet" {
  type = list(object({
    name           = string
    address_prefix = list(string)
  }))
}

variable "main_address_space" {
  type = list(string)
}
variable "subnet1_address_space" {
  type = list(string)
}
variable "subnet2_address_space" {
  type = list(string)
}
