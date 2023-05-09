resource "azurerm_resource_group" "resourcegroup" {
  location = "North Europe"
  name     = "lmmanresourcegroup"
}

resource "azurerm_databricks_workspace" "workspace" {
  location            = azurerm_resource_group.resourcegroup.location
  name                = "lmmandatabricksworkspace"
  resource_group_name = azurerm_resource_group.resourcegroup.name
  sku                 = "premium"

  tags = {
    Environment = "dev"
  }
}

# data "databricks_node_type" "smallest" {
#   depends_on = [
#     azurerm_databricks_workspace.workspace
#   ]
#   local_disk = true
# }

# data "databricks_spark_version" "latest_lts" {
#   depends_on = [
#     azurerm_databricks_workspace.workspace
#   ]
#   long_term_support = true
# }

# resource "databricks_cluster" "single_node" {
#   depends_on              = [azurerm_databricks_workspace.workspace]
#   cluster_name            = "lmman_single_node_cluster"
#   spark_version           = data.databricks_spark_version.latest_lts.id
#   node_type_id            = data.databricks_node_type.smallest.id
#   num_workers             = 1
#   autotermination_minutes = 20
#   spark_conf = {"spark.databricks.io.cache.enabled" : true}
# }

resource "azurerm_storage_account" "storage" {
  name                     = "lmmanstorageaccountdev"
  location                 = azurerm_resource_group.resourcegroup.location
  resource_group_name      = azurerm_resource_group.resourcegroup.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = true

  tags = {
    environment = "dev"
  }
}

resource "azurerm_storage_container" "container" {
  name                  = "lmmancontainer"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "filesystem" {
  name               = "filesystem"
  storage_account_id = azurerm_storage_account.storage.id
}

# Create a Synapse workspace
resource "azurerm_synapse_workspace" "synapse_ws" {
  name                = "lmman-synapse-workspace"
  location                 = azurerm_resource_group.resourcegroup.location
  resource_group_name      = azurerm_resource_group.resourcegroup.name
storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.filesystem.id
  sql_administrator_login          = "synapseadmin"
  sql_administrator_login_password = "Password1234!" # Replace this with a strong password

  tags = {
    environment = "dev"
  }
  # Link an existing managed identity to the Synapse workspace for managed resource access
  identity {
    type = "SystemAssigned"
  }
}
