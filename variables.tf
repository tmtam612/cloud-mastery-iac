variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "instance_count" {
  type = string
}

variable "topxteam_dns_label" {
  type = string
}

variable "cloudmastery_dns_label" {
  type = string
}

variable "cloudmastery_public_ip_address_name" {
  type = string
}

variable "topxteam_public_ip_address_name" {
  type = string
}

variable "resource_group_abbrevation" {
  type = string
}

variable "resource_group_profile" {
  type = string
}

variable "ip_address_resource_group" {
  type = string
}

variable "user_assigned_identity_abbrevation" {
  type = string
}

variable "user_assigned_identity_profile" {
  type = string
}

variable "network_contributor_role" {
  type = string
}

variable "default_contributor_role" {
  type = string
}

variable "vnet_combined_vars" {
  type = map(string)
  default = {
    virtual_network_abbrevation = ""
    virtual_network_profile     = ""
    virtual_ip_address          = ""
    subnet_abbrevation          = ""
  }
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

variable "list_subnet" {
  type = list(object({
    name           = string
    address_prefix = list(string)
  }))
}

variable "storage_combined_vars" {
  type = map(string)
  default = {
    storage_account_abbrevation   = ""
    storage_account_profile       = ""
    storage_container_abbrevation = ""
    storage_container_profile     = ""
  }
}

variable "account_app_service_combined_vars" {
  type = map(string)
  default = {
    app_service_abbrevation            = ""
    app_service_profile                = ""
    app_service_connection_abbrevation = ""
    app_service_connection_profile     = ""
    app_service_authentication         = ""
    app_service_plan_abbrevation       = ""
    app_service_plan_profile           = ""
    service_plan_sku                   = ""
    os_type                            = ""
    connect_to_db                      = false
    identity_type                      = ""
  }
}
variable "cosmosdb_combined_vars" {
  type = map(string)
  default = {
    cosmosdb_account_abbrevation      = ""
    cosmosdb_account_profile          = ""
    cosmosdb_database_abbrevation     = ""
    cosmosdb_database_profile         = ""
    cosmos_db_consistency_level       = ""
    cosmos_db_max_interval_in_seconds = ""
    cosmos_db_max_staleness_prefix    = ""
    cosmos_db_offer_type              = ""
    database_throughput               = ""
    first_geo_location                = ""
    second_geo_location               = ""
    default_identity_type             = ""
    identity_type                     = ""
  }
}

variable "key_vault_combined_vars" {
  type = map(string)
  default = {
    key_vault_location           = ""
    key_vault_abbrevation        = ""
    key_vault_profile            = ""
    key_vault_sku_name           = ""
    soft_delete_retention_days   = ""
    key_permissions              = ""
    secret_permissions           = ""
    storage_permissions          = ""
    key_vault_secret_abbrevation = ""
    key_vault_secret_profile     = ""
    key_vault_secret_value       = ""
    key_vault_key_abbrevation    = ""
    key_vault_key_profile        = ""
    key_vault_key_type           = ""
    key_vault_key_size           = ""
    time_before_expiry           = ""
    expire_after                 = ""
    notify_before_expiry         = ""
  }
}

variable "key_permissions" {
  type = list(string)
}

variable "secret_permissions" {
  type = list(string)
}

variable "storage_permissions" {
  type = list(string)
}

variable "key_opts" {
  type = list(string)
}

variable "service_bus_combined_vars" {
  type = map(string)
  default = {
    service_bus_abbrevation       = ""
    service_bus_profile           = ""
    service_bus_queue_abbrevation = ""
    service_bus_queue_profile     = ""
    sku_name                      = ""
  }
}

variable "acr_combined_vars" {
  type = map(string)
  default = {
    project_name_without_dash = ""
    acr_abbrevation           = ""
    acr_profile               = ""
    sku                       = ""
    location                  = ""
    zone_redundancy_enabled   = ""
  }
}

variable "aks_combined_vars" {
  type = map(string)
  default = {
    aks_abbrevation       = ""
    aks_profile           = ""
    vm_size               = ""
    node_count            = ""
    aks_dns_prefix        = ""
    aks_identity_type     = ""
    network_plugin        = ""
    node_pool_profile     = ""
    node_pool_abbrevation = ""
    default_node_name     = ""
    node_pool_name        = ""
    node_priority         = ""
  }
}

variable "k8s_combined_vars" {
  type = map(string)
  default = {
    cert_manager_name                          = ""
    cert_manager_repository                    = ""
    cert_manager_chart                         = ""
    cert_manager_version                       = ""
    cert_manager_wait                          = ""
    cert_manager_set_name                      = ""
    cert_manager_set_value                     = ""
    actions_runner_controller_name             = ""
    actions_runner_controller_repository       = ""
    actions_runner_controller_chart            = ""
    actions_runner_controller_namespace        = ""
    actions_runner_controller_create_namespace = ""
    actions_runner_controller_wait             = ""
    actions_runner_controller_set_name         = ""
    actions_runner_controller_set_value        = ""
    actions_runner_controller_set_github_name  = ""
    actions_runner_controller_set_github_value = ""
    argocd_name                                = ""
    argocd_repository                          = ""
    argocd_chart                               = ""
    argocd_namespace                           = ""
    argocd_create_namespace                    = ""
    argocd_version                             = ""
  }
}

