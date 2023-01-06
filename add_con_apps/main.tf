# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.96.0" # Establishes a forced version
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.18.0"
    }
    azapi = {
      source  = "Azure/azapi"
    }
  }

  # backend "azurerm" {
  # }
  # required_version = ">= 0.14.11"
}

provider "azurerm" {
  features {}
  #   subscription_id = "!__subscription_id__!"
  #   client_id       = "!__client_id__!"
  #   client_secret   = "!__client_secret__!"
  #   tenant_id       = "!__tenant_id__!"
}

provider "azuread" {
  #   tenant_id = "!__tenant_id__!"
}

######################################
# Data Imports of Existing Resources #
######################################
data "azurerm_client_config" "current" {
}
data "azuread_client_config" "current" {}

data "azurerm_resource_group" "resource_group" {
  name = var.rg_name
}
data "azapi_resource" "aca-environment" {
  name = var.aca-name
  type      = "Microsoft.App/managedEnvironments@2022-03-01"
  parent_id = data.azurerm_resource_group.resource_group.id
}


######################################
# Creating multiple container Apps  #
######################################
resource "azapi_resource" "aca" {
  for_each  = { for ca in var.container_apps: ca.name => ca}
  type      = "Microsoft.App/containerApps@2022-03-01"
  parent_id = data.azurerm_resource_group.resource_group.id
  location  = data.azurerm_resource_group.resource_group.location
  name      = each.value.name
  
  body = jsonencode({
    properties: {
      managedEnvironmentId = data.azapi_resource.aca-environment.id
      configuration = {
        ingress = {
          external = each.value.ingress_enabled
          targetPort = each.value.ingress_enabled?each.value.containerPort: null
        }
      }
      template = {
        containers = [
          {
            name = each.value.name
            image = "${each.value.image}:${each.value.tag}"
            resources = {
              cpu = each.value.cpu_requests
              memory = each.value.mem_requests
            }
          }         
        ]
        scale = {
          minReplicas = each.value.min_replicas
          maxReplicas = each.value.max_replicas
        }
      }
    }
  })
  tags = {
    Environment : var.environment
  }
  depends_on      = [data.azurerm_resource_group.resource_group]
}