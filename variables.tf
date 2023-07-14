
# pipeline variables

variable "ado_org_service_url" {
  type        = string
  description = "Org service url for Azure DevOps"
  default = "https://dev.azure.com/apatel0999/"
}

# repo to link to pipeline
variable "ado_github_repo" {
  type        = string
  description = "Name of the repository in the format <GitHub Org>/<RepoName>"
  default     = "patelavtx/newspoke13-kv"
}

variable "ado_pipeline_yaml_path_1" {
  type        = string
  description = "Path to the yaml for the first pipeline"
  default     = "./azure-pipelines.yaml"
}

# GH - PAT providing access to repo
variable "ado_github_pat" {
  type        = string
  description = "Personal authentication token for GitHub repo"
  sensitive   = true
}


variable "prefix" {
  type        = string
  description = "Naming prefix for resources"
  default     = ""
}

variable "az_location" {
  type    = string
  default = "westeurope"
}

variable "az_container_name" {
  type        = string
  description = "Name of container on storage account for Terraform state"
  default     = "terraform-state"
}

variable "az_state_key" {
  type        = string
  description = "Name of key in storage account for Terraform state"
  default     = "adoterraform.tfstate"
}

variable "az_client_id" {
  type        = string
  description = "Client ID with permissions to create resources in Azure, use env variables"
}

variable "az_client_secret" {
  type        = string
  description = "Client secret with permissions to create resources in Azure, use env variables"
}

variable "az_subscription" {
  type        = string
  description = "Client ID subscription, use env variables"
}

variable "az_subscription_name" {
   type = string
   description = "sub name"
}

variable "az_endpoint" {
   type = string
   description = "azconn"
   default = "azconn"
}

variable "gh_endpoint" {
   type = string
   description = "ghconn"
   default = "ghconn"
}

variable "kv_endpoint" {
   type = string
   description = "kvconn"
   default = "kvconn"
}

variable "azdevops_env" {
   type = string
   description = "ghconn"
   default = "test"
}

variable "az_tenant" {
  type        = string
  description = "Client ID Azure AD tenant, use env variables"
}

resource "random_integer" "suffix" {
  min = 10
  max = 99
}

locals {
  ado_project_name        = "${var.prefix}-project-${random_integer.suffix.result}"
  ado_project_description = "Project for ${var.prefix}"
  ado_project_visibility  = "private"
  ado_pipeline_name_1     = "${var.prefix}-pipeline-1"

  az_resource_group_name  = "${var.prefix}${random_integer.suffix.result}"
  az_storage_account_name = "${lower(var.prefix)}${random_integer.suffix.result}"
  az_key_vault_name = "${var.prefix}${random_integer.suffix.result}"

# keyvault doesn't like underscore, therefore dashes used. 
  pipeline_variables = {
    controller-ip = var.controller-ip
    ctrl-password = var.ctrl-password
    account = var.account
    name = var.name
    transit-gw = var.transit_gw
    cidr = var.cidr
    region = var.region
    #gw1-snat = var.gw1_snat
    #gw2-snat = var.gw2_snat
    #dnatip = var.dnatip
    #dnatip2 = var.dnatip2
    #dstcidr = var.dstcidr
    #dstcidr2 = var.dstcidr2
    #nat-attached = var.nat_attached
    attached = var.attached
    ha-gw = var.ha_gw
    controller-nsg = var.controller-nsg
    controller-rg = var.controller-rg
    agent-name = var.agent-name
    agent-rg = var.agent-rg
    #spoke-cidrs = var.spoke_cidrs

    #az-client-id = var.az_client_id                # set as TF_VAR
    #az-client-secret = var.az_client_secret        # set as TF_VAR
    #az-subscription = data.azurerm_client_config.current.subscription_id
    #az-tenant = data.azurerm_client_config.current.tenant_id
  }
}


###  Keyvault (VG variables) referenced above

variable "controller-ip" {
  description = "Set controller ip"
  type        = string
}

variable "ctrl-password" {
    type = string
}

variable "account" {
    type = string
}

variable "name" {
    type = string
}

variable "transit_gw" {
    type = string
}

variable "cidr" {  
  description = "Set vpc cidr"
  type        = string
}

variable "region" {
  description = "Set regions"
  type        = string
}


# This one to omitted here when not using KV
variable "spoke_cidrs" {
    description = "spoke vpc range"
    type = string
}


variable "gw1_snat" {
  type        = string
}

variable "gw2_snat" {
  type        = string
}

variable "dnatip" {
  type        = string
}

variable "dnatip2" {
  type        = string
}

variable "dstcidr" {
  type        = string
}

variable "dstcidr2" {
  type        = string
}


variable "nat_attached" {
  default     = "true"
}


variable "attached" {
  default     = "true"
}

variable "ha_gw" {
  description = "Required when spoke is HA pair."
  default     = true
}
/*
variable "tags" {
  type = map(string)
  description = ""
  default = { ProjectName = "spoke-ado4"
              BusinessOwnerEmail = "apatel@aviatrix.com" 
            }
}
*/

variable "environ" {
    type = string
}

variable "controller-nsg" {
    type = string
}

variable "controller-rg" {
    type = string
}

variable "agent-name" {
    type = string
}

variable "agent-rg" {
    type = string
}

