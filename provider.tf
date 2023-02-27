terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
      version = "1.10.1"
    }
  }
}
provider "databricks" {
  azure_workspace_resource_id = azurerm_databricks_workspace.workspace.id
  azure_client_id             = ""
  azure_client_secret         = ""
  azure_tenant_id             = ""
}
provider "azurerm" {
  features {}
  client_id       = ""
  client_secret   = ""
  tenant_id       = ""
  subscription_id = ""
}