resource "azurerm_resource_group_template_deployment" "aks_scheduler" {
  for_each            = { for w in local.workflows : "${w.cluster_key}-${w.action}" => w }
  name                = "aks-scheduler-${each.value.cluster_key}-${each.value.action}"
  resource_group_name = local.clusters[each.value.cluster_key].resource_group
  deployment_mode     = "Incremental"

  template_content = jsonencode({
    "$schema"        = "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion" = "1.0.0.0",
    "parameters"     = {},
    "variables"      = {},
    "resources" = [
      {
        "type"       = "Microsoft.Logic/workflows",
        "apiVersion" = "2017-07-01",
        "name"       = "aks-scheduler-${each.value.cluster_key}-${each.value.action}",
        "location"   = local.clusters[each.value.cluster_key].location,
        "identity" = {
          "type" = "SystemAssigned"
        },
        "tags" = {
          "resource_group"  = local.clusters[each.value.cluster_key].resource_group,
          "subscription_id" = local.clusters[each.value.cluster_key].subscription_id,
          "aks_name"        = local.clusters[each.value.cluster_key].cluster_name,
          "trigger_days"    = each.value.schedule.type == "monthly" ? "${each.value.schedule.week}${each.value.schedule.day}" : join(",", each.value.schedule.days),
          "trigger_time"    = "${each.value.schedule.hour}:${each.value.schedule.minute}",
          "time_zone"       = "UTC",
          "enabled"         = each.value.enabled ? "true" : "false"
        },
        "properties" = {
          "definition" = {
            "$schema"        = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#",
            "contentVersion" = "1.0.0.0",
            "parameters"     = {},
            "triggers" = {
              "Recurrence" = {
                "type"       = "Recurrence",
                "recurrence" = each.value.recurrence
              }
            },
            "actions" = {
              "${each.value.action}_AKS" = {
                "type" = "Http",
                "inputs" = {
                  "method" = "POST",
                  "uri"    = "https://management.azure.com/subscriptions/${local.clusters[each.value.cluster_key].subscription_id}/resourceGroups/${local.clusters[each.value.cluster_key].resource_group}/providers/Microsoft.ContainerService/managedClusters/${local.clusters[each.value.cluster_key].cluster_name}/${each.value.action}?api-version=2023-01-01",
                  "authentication" = {
                    "type" = "ManagedServiceIdentity"
                  }
                }
              }
            },
            "outputs" = {}
          },
          "parameters" = {},
          "state"      = each.value.enabled ? "Enabled" : "Disabled"
        }
      }
    ],
    "outputs" = {}
  })
}

resource "azurerm_role_definition" "aks_start_stop" {
  for_each = local.clusters
  name     = "AKS StartStop Operator - ${each.key}"
  scope    = data.azurerm_resource_group.clusters[each.key].id
  permissions {
    actions = [
      "Microsoft.ContainerService/managedClusters/start/action",
      "Microsoft.ContainerService/managedClusters/stop/action"
    ]
    not_actions = []
  }
  assignable_scopes = [data.azurerm_resource_group.clusters[each.key].id]
}

resource "azurerm_role_assignment" "aks_start" {
  for_each           = local.clusters
  scope              = data.azurerm_kubernetes_cluster.clusters[each.key].id
  role_definition_id = azurerm_role_definition.aks_start_stop[each.key].role_definition_resource_id
  principal_id       = data.azurerm_logic_app_workflow.logic_apps["${each.key}-start"].identity[0].principal_id
}

resource "azurerm_role_assignment" "aks_stop" {
  for_each           = local.clusters
  scope              = data.azurerm_kubernetes_cluster.clusters[each.key].id
  role_definition_id = azurerm_role_definition.aks_start_stop[each.key].role_definition_resource_id
  principal_id       = data.azurerm_logic_app_workflow.logic_apps["${each.key}-stop"].identity[0].principal_id
}
