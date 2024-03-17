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

variable "user_assigned_identity" {
  type = string
}

variable "combined_vars" {
  type = map(string)
}
