data "azurerm_kubernetes_cluster" "clusters" {
  for_each            = local.clusters
  name                = each.value.cluster_name
  resource_group_name = each.value.resource_group
}

data "azurerm_resource_group" "clusters" {
  for_each = local.clusters
  name     = each.value.resource_group
}

data "azurerm_resources" "logic_apps" {
  for_each            = { for w in local.workflows : "${w.cluster_key}-${w.action}" => w }
  resource_group_name = local.clusters[each.value.cluster_key].resource_group
  name                = "aks-scheduler-${each.value.cluster_key}-${each.value.action}"
  type                = "Microsoft.Logic/workflows"
  depends_on          = [azurerm_resource_group_template_deployment.aks_scheduler]
}

data "azurerm_logic_app_workflow" "logic_apps" {
  for_each            = { for w in local.workflows : "${w.cluster_key}-${w.action}" => w }
  name                = "aks-scheduler-${each.value.cluster_key}-${each.value.action}"
  resource_group_name = local.clusters[each.value.cluster_key].resource_group
  depends_on          = [azurerm_resource_group_template_deployment.aks_scheduler]
}