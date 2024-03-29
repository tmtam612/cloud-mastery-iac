#local
project_name   = "topx"
environment    = "dev"
region         = "westus3"
instance_count = "001"

#resource group
resource_group_abbrevation = "rgs"
resource_group_profile     = "core"

#user assigned identity
user_assigned_identity_abbrevation = "uai"
user_assigned_identity_profile     = "core"

#vnet
vnet_combined_vars = {
  virtual_network_abbrevation = "vnet"
  virtual_network_profile     = "core"
  subnet_abbrevation          = "snet1"
}
virtual_ip_address = ["10.0.0.0/16"]
list_subnet = [
  {
    name           = "subnet_account_service"
    address_prefix = ["10.0.10.0/28"] //from "10.0.10.0" to "10.0.10.15"
  }
]

#storage
storage_combined_vars = {
  storage_account_abbrevation   = "sa"
  storage_account_profile       = "core"
  storage_container_abbrevation = "sc"
  storage_container_profile     = "core"
}


#app service
account_app_service_combined_vars = {
  app_service_abbrevation            = "as"
  app_service_profile                = "asacc"
  app_service_connection_abbrevation = "asc"
  app_service_connection_profile     = "connect1"
  app_service_authentication         = "userAssignedIdentity"
  app_service_plan_abbrevation       = "asp"
  app_service_plan_profile           = "plan1"
  service_plan_sku                   = "B1"
  os_type                            = "Linux"
  connect_to_db                      = true
  identity_type                      = "UserAssigned"
}

#cosmos db
cosmosdb_combined_vars = {
  cosmosdb_account_abbrevation      = "cma"
  cosmosdb_account_profile          = "core"
  cosmosdb_database_abbrevation     = "cmdb"
  cosmosdb_database_profile         = "core"
  cosmos_db_consistency_level       = "BoundedStaleness"
  cosmos_db_max_interval_in_seconds = 300
  cosmos_db_max_staleness_prefix    = 100000
  cosmos_db_offer_type              = "Standard"
  database_throughput               = 400
  first_geo_location                = "eastus"
  second_geo_location               = "westus"
  default_identity_type             = "UserAssignedIdentity"
  identity_type                     = "UserAssigned"
}

#key vault
key_vault_combined_vars = {
  key_vault_location           = "asia"
  key_vault_abbrevation        = "kv"
  key_vault_profile            = "core"
  key_vault_sku_name           = "standard"
  soft_delete_retention_days   = 7
  key_vault_secret_abbrevation = "kvc"
  key_vault_secret_profile     = "core"
  key_vault_secret_value       = "supersecretvalue"
  key_vault_key_abbrevation    = "kvk"
  key_vault_key_profile        = "core"
  key_vault_key_type           = "RSA"
  key_vault_key_size           = 2048
  time_before_expiry           = "P30D"
  expire_after                 = "P90D"
  notify_before_expiry         = "P90D"
}
key_permissions     = ["List", "Create", "Delete", "Get", "Purge", "Recover", "Update", "GetRotationPolicy", "SetRotationPolicy"]
secret_permissions  = ["Get", "List", "Set", "Delete", "Recover", "Backup", "Restore", "Purge"]
storage_permissions = ["Get", "List"]
key_opts = [
  "decrypt",
  "encrypt",
  "sign",
  "unwrapKey",
  "verify",
  "wrapKey",
]

#service bus
service_bus_combined_vars = {
  service_bus_abbrevation       = "sb"
  service_bus_profile           = "core"
  service_bus_queue_abbrevation = "sbq"
  service_bus_queue_profile     = "core"
  sku_name                      = "Standard"
}

#aks
aks_combined_vars = {
  aks_abbrevation           = "aks"
  aks_profile               = "core"
  kubernetes_instance_count = 3
  vm_size                   = "standard_b2s"
  node_count                = 1
  aks_dns_prefix            = "aksdnsprefix"
  aks_identity_type         = "UserAssigned"
  node_pool_abbrevation     = "np"
  node_pool_profile         = "core"
  node_pool_instance_count  = 1
  default_node_name         = "defaultnode"
  node_pool_name            = "topxnodepool"
  node_priority             = "Spot"
}
