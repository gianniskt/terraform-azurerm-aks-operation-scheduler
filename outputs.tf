output "logic_app_workflow_ids" {
  description = "IDs of the created Logic App workflows"
  value       = { for k, v in data.azurerm_logic_app_workflow.logic_apps : k => v.id }
}

output "logic_app_workflow_names" {
  description = "Names of the created Logic App workflows"
  value       = { for k, v in data.azurerm_logic_app_workflow.logic_apps : k => v.name }
}

output "role_definition_ids" {
  description = "IDs of the custom role definitions created"
  value       = { for k, v in azurerm_role_definition.aks_start_stop : k => v.role_definition_resource_id }
}

output "role_assignments" {
  description = "Role assignments for the Logic Apps"
  value = merge(
    { for k, v in azurerm_role_assignment.aks_start : "${k}-start" => v.id },
    { for k, v in azurerm_role_assignment.aks_stop : "${k}-stop" => v.id }
  )
}

output "arm_template_deployment_ids" {
  description = "IDs of the ARM template deployments"
  value       = { for k, v in azurerm_resource_group_template_deployment.aks_scheduler : k => v.id }
}