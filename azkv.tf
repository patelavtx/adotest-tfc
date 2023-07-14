
#  Setting up Key Vault for secrets and variables for tfvars


provider "azurerm" {
  features {}
}


# get current azure creds and subscription that TF code is running under (export TF_VAR)
data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}


resource "azurerm_resource_group" "setup" {
  name     = local.az_resource_group_name
  location = var.az_location
}


# Create a Key Vault 
resource "azurerm_key_vault" "setup" {
  name = local.az_key_vault_name
  location = azurerm_resource_group.setup.location
  resource_group_name = azurerm_resource_group.setup.name
  tenant_id = data.azurerm_client_config.current.tenant_id
  sku_name = "standard"
}


# Set access policies - for current client creating KV  ; permissions need to start with upper case letter otherwise TF errors
# Object_id related to SP used
# Granted full access (but probably could be restricted to just secret_permissions)
resource "azurerm_key_vault_access_policy" "policy1" {
  key_vault_id = azurerm_key_vault.setup.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Get", "List", "Update", "Create", "Decrypt", "Encrypt", "UnwrapKey", "WrapKey", "Verify", "Sign",
  ]

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Purge", "Recover", "Backup"
  ]

  certificate_permissions = [
    "Get", "List", "Create", "Import", "Delete", "Update",
  ]
}


# Populate with secrets ; variables to be used by the pipeline using foreach loop; locals specified in variables.tf 
resource "azurerm_key_vault_secret" "pipeline" {
  depends_on = [
    azurerm_key_vault_access_policy.policy1
  ]
  for_each = local.pipeline_variables        
  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.setup.id
}


# Key Vault connection setup
## There needs to be a service connection to an Azure subscription with the key vault
## https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/serviceendpoint_azurerm

# conn to azurerm subs from ado,
resource "azuredevops_serviceendpoint_azurerm" "key_vault" {
  project_id = azuredevops_project.project.id
  service_endpoint_name = var.kv_endpoint
  description = "Azure Service Endpoint for Key Vault Access"

  credentials {
    serviceprincipalid = var.az_client_id
    serviceprincipalkey = var.az_client_secret         # using atulavtx-sst2 ; declared via env variables
  }

  azurerm_spn_tenantid = data.azurerm_client_config.current.tenant_id
  azurerm_subscription_id = data.azurerm_client_config.current.subscription_id
  azurerm_subscription_name = data.azurerm_subscription.current.display_name
}

# auth project to use kv resource
resource "azuredevops_resource_authorization" "kv_auth" {
  project_id  = azuredevops_project.project.id
  resource_id = azuredevops_serviceendpoint_azurerm.key_vault.id
  authorized  = true
}

# Key Vault task is here: https://docs.microsoft.com/en-us/azure/devops/pipelines/tasks/deploy/azure-key-vault?view=azure-devops
