#local
project_name   = "cloud-mastery"
environment    = "dev"
region         = "eastus"
instance_count = "1"
dns_label      = "cloudmastery"
#resource group
resource_group_abbrevation = "rgs"
resource_group_profile     = "core"
ip_address_resource_group  = "topx-rg-backend-nonprod-eastus"
#user assigned identity
user_assigned_identity_abbrevation = "uai"
user_assigned_identity_profile     = "core"
user_assigned_role_definition_name = "Network Contributor"
#vnet
vnet_combined_vars = {
  virtual_network_abbrevation = "vnet"
  virtual_network_profile     = "core"
  subnet_abbrevation          = "snet1"
  subnet1                     = "subnet1"
  subnet2                     = "subnet1"
}
main_address_space    = ["10.0.0.0/8"]
subnet1_address_space = ["10.0.0.0/19"]
subnet2_address_space = ["10.0.32.0/19"]
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
  aks_abbrevation                = "aks"
  aks_profile                    = "core"
  kubernetes_instance_count      = 3
  vm_size                        = "standard_b2s"
  node_count                     = 1
  aks_dns_prefix                 = "cloudmastery"
  aks_identity_type              = "UserAssigned"
  default_node_name              = "defaultnode"
  node_pool_name                 = "topxnodepool"
  node_priority                  = "Spot"
  sku_tier                       = "Free" //change to standard when on production
  oidc_issuer_enabled            = true   //enable openID connect
  workload_identity_enabled      = true   //enable workload identity
  automatic_channel_upgrade      = "stable"
  private_cluster_enabled        = false
  enable_auto_scaling            = true
  node_type                      = "VirtualMachineScaleSets"
  min_count                      = 1
  max_count                      = 10
  network_profile_network_plugin = "azure"
  network_profile_dns_service_ip = "10.0.64.10"
  network_profile_service_cidr   = "10.0.64.0/19"
}

#k8s
k8s_combined_vars = {
  cert_manager_name                          = "cert-manager"
  cert_manager_repository                    = "https://charts.jetstack.io"
  cert_manager_chart                         = "cert-manager"
  cert_manager_version                       = "v1.14.0"
  cert_manager_wait                          = true
  cert_manager_set_name                      = "installCRDs"
  cert_manager_set_value                     = true
  actions_runner_controller_name             = "actions-runner-controller"
  actions_runner_controller_repository       = "https://actions-runner-controller.github.io/actions-runner-controller"
  actions_runner_controller_chart            = "actions-runner-controller"
  actions_runner_controller_namespace        = "self-hosted-runners"
  actions_runner_controller_create_namespace = true
  actions_runner_controller_wait             = true
  actions_runner_controller_set_name         = "authSecret.create"
  actions_runner_controller_set_value        = true
  actions_runner_controller_set_github_name  = "authSecret.github_token"
  actions_runner_controller_set_github_value = "<your-PAT>"
  argocd_name                                = "argocd"
  argocd_repository                          = "https://argoproj.github.io/argo-helm"
  argocd_chart                               = "argo-cd"
  argocd_namespace                           = "argocd"
  argocd_create_namespace                    = true
  argocd_version                             = "3.35.4"
  ingress_name                               = "ingress-nginx"
  ingress_repository                         = "https://kubernetes.github.io/ingress-nginx"
  ingress_chart                              = "ingress-nginx"
  ingress_namespace                          = "ingress-controller"
  ingress_create_namespace                   = true
}
