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

  backend "azurerm" {
  }
  required_version = ">= 0.14.11"
}

provider "azurerm" {
  features {}
    subscription_id = "!__subscription_id__!"
    client_id       = "!__client_id__!"
    client_secret   = "!__client_secret__!"
    tenant_id       = "!__tenant_id__!"
}

provider "azuread" {
    tenant_id = "!__tenant_id__!"
}

######################################
# Data Imports of Existing Resources #
######################################
data "azurerm_client_config" "current" {
}
data "azuread_client_config" "current" {}


##################
# Resource Group #
##################
resource "azurerm_resource_group" "resource_group" { #Creation of new Resource Group would be actual code snippet
  name     = "${var.customer_prefix}-rg-${var.environment}"
  location = var.location
}

######################
# Container Registry #
#####################
resource "azurerm_container_registry" "Containerreg" {
  name                    = "${var.customer_prefix}cr234"
  location                = azurerm_resource_group.resource_group.location
  resource_group_name     = azurerm_resource_group.resource_group.name
  sku                     = var.container_reg_sku
  public_network_access_enabled = var.container_reg_public_access
  admin_enabled           = true
  # admin_username          = "${var.customer_prefix}USER"
  # admin_password          = "${var.customer_prefix}USER123@"

  tags = {
    Environment : var.environment
  }
  depends_on = [azurerm_resource_group.resource_group]
}

##################
# Log Analytics #
##################
resource "azurerm_log_analytics_workspace" "logAnalytics" {
  name                = "${var.customer_prefix}-la-${var.environment}"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    Environment : var.environment
  }
  depends_on = [azurerm_resource_group.resource_group]
}

##################
# ACA Environment#
##################
resource "azapi_resource" "aca-environment" {
  name      = "${var.customer_prefix}-env-${var.environment}"
  type      = "Microsoft.App/managedEnvironments@2022-03-01"
  location  = azurerm_resource_group.resource_group.location
  parent_id = azurerm_resource_group.resource_group.id
  body = jsonencode({
    properties = {
      appLogsConfiguration = {
        destination               = "log-analytics"
        logAnalyticsConfiguration = {
          customerId              = azurerm_log_analytics_workspace.logAnalytics.workspace_id
          sharedKey               = azurerm_log_analytics_workspace.logAnalytics.primary_shared_key
        }
      }
    }
  })

  tags = {
    Environment : var.environment
  }
  depends_on = [azurerm_resource_group.resource_group]
}


#################
# Container App #
#################

resource "azapi_resource" "container_app" {
  name      = "${var.customer_prefix}-aca-${var.environment}"
  location  = azurerm_resource_group.resource_group.location
  parent_id = azurerm_resource_group.resource_group.id
  type      = "Microsoft.App/containerApps@2022-03-01"
  schema_validation_enabled = false
  body = jsonencode({
    properties = {
      managedEnvironmentId = azapi_resource.aca-environment.id
      configuration = {
        activeVersionMode = "multiple"
        ingress = {
          targetPort = 80
          external   = true
          allowInsecure = false
        },
        registries = [
          {
            server            = azurerm_container_registry.Containerreg.login_server
            username          = azurerm_container_registry.Containerreg.admin_username
            passwordSecretRef = "registry-password"
          }
        ],
        secrets : [
          {
            name = "registry-password"
            # Todo: Container apps does not yet support Managed Identity connection to ACR
            value = azurerm_container_registry.Containerreg.admin_password
          }
        ]
      },
      template = {
        containers = [
          {
            image = "mcr.microsoft.com/azuredocs/aci-tutorial-sidecar"
            name  = "sidecar",
            env : [
              {
                "name" : "EnvVariable",
                "value" : "Value"
              }
            ]
          }
        ]
      }
    }
  })
  # This seems to be important for the private registry to work(?)
  ignore_missing_property = true
  response_export_values = ["properties.configuration.ingress"]

  tags = {
    Environment : var.environment
  }
  depends_on = [azurerm_resource_group.resource_group, azurerm_container_registry.Containerreg]
}
