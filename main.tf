resource "azurerm_resource_group" "resourcegroup" {
  location = "North Europe"
  name     = "databricksRG"
}

resource "azurerm_databricks_workspace" "workspace" {
  location            = azurerm_resource_group.resourcegroup.location
  name                = "azureCRDB"
  resource_group_name = azurerm_resource_group.resourcegroup.name
  sku                 = "premium"

  tags = {
    Environment = "dev"
  }
}

data "databricks_node_type" "smallest" {
#   name = "lmman_databricks_node_type"
  depends_on = [
    azurerm_databricks_workspace.workspace
  ]
  local_disk = true
}

data "databricks_spark_version" "latest_lts" {
#   name = "lmman_databricks_spark_version"
  depends_on = [
    azurerm_databricks_workspace.workspace
  ]
  long_term_support = true
}

# resource "databricks_instance_pool" "pool" {
#   instance_pool_name = "CodeRedPool"
#   min_idle_instances = 0
#   max_capacity       = 10
#   node_type_id       = data.databricks_node_type.smallest.id

#   idle_instance_autotermination_minutes = 10
# }

resource "databricks_cluster" "single_node" {
  depends_on              = [azurerm_databricks_workspace.workspace]
  cluster_name            = "lmman_single_node_cluster"
  spark_version           = data.databricks_spark_version.latest_lts.id
  node_type_id            = data.databricks_node_type.smallest.id
  num_workers        = 1
  autotermination_minutes = 20
  spark_conf = {"spark.databricks.io.cache.enabled" : true}
#   tags = {
#     "createdby" = "lmman"
#     "environment" = "dev"
#     "project"     = "my-project"
#     }
}