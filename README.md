# Terraform AzureRM AKS Operation Scheduler

This Terraform module provisions Azure Logic Apps Consumption workflows to automatically start and stop AKS clusters on customizable schedules (weekly or monthly).

## Quick Start

### Calling the Module

To use this module in your Terraform configuration, add the following:

**Terraform Registry**: [aks-operation-scheduler](https://registry.terraform.io/modules/gianniskt/aks-operation-scheduler/azurerm)
```hcl
module "aks_operation_scheduler" {
  source  = "gianniskt/aks-operation-scheduler/azurerm"
  version = "~> 1.0"

  clusters = {
    my-cluster = {
      resource_group  = "MyRG"                    # Replace with your resource group name
      location        = "eastus"                  # Replace with your Azure region
      subscription_id = "your-subscription-id"    # Replace with your Azure subscription ID
      cluster_name    = "my-aks-cluster"          # Replace with your AKS cluster name
      start_schedule = {
        type   = "weekly"                              # "weekly" or "monthly"
        days   = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]  # Days to run (weekly) or day name (monthly)
        hour   = 8                                     # Hour in UTC (0-23)
        minute = 0                                     # Minute (0-59)
      }
      stop_schedule = {
        type   = "weekly"                              # "weekly" or "monthly"
        days   = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]  # Days to run (weekly) or day name (monthly)
        hour   = 18                                    # Hour in UTC (0-23)
        minute = 0                                     # Minute (0-59)
      }
      enabled_start = true  # Enable/disable start scheduling
      enabled_stop  = true  # Enable/disable stop scheduling
    }
  }
}
```

## Architecture

[View architecture diagram](https://github.com/gianniskt/terraform-azurerm-aks-operation-scheduler/blob/main/diagrams/aks-operation-scheduler-diagram.png)

The solution uses Azure Logic Apps Consumption to schedule start and stop operations for AKS clusters. For each cluster defined in the `clusters` variable, two workflows are created:
- One for starting the cluster based on the specified schedule and start time.
- One for stopping the cluster based on the specified schedule and stop time.

Each workflow uses a Recurrence trigger to run on the defined days at the specified UTC time, and an "Invoke Resource Action" to call the Azure Resource Manager API to start or stop the AKS cluster.

The Logic Apps are assigned system-managed identities with a custom "AKS StartStop Operator" role on the respective AKS clusters to perform the operations.

The workflows are deployed using ARM templates via Terraform's `azurerm_resource_group_template_deployment` for full automation.

## Prerequisites

- Azure CLI installed and authenticated (`az login`)
- Terraform >= 1.0
- Access to the Azure subscription with permissions to create Logic Apps, deploy ARM templates, assign roles, create custom roles, and read AKS clusters
- ARM template deployment is mandatory, as it is used to provision the Logic Apps with the required configurations and MSI.

## Custom Schedules

The module supports flexible scheduling:

### Weekly Schedules Example
Specify `type = "weekly"` and a list of `days`:

```hcl
start_schedule = {
  type   = "weekly"
  days   = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
  hour   = 8
  minute = 0
}
```

### Monthly Schedules Example
Specify `type = "monthly"`, `week` (1-4, or -1 for last), and `day`:

```hcl
start_schedule = {
  type  = "monthly"
  week  = 1  # 1st Monday
  day   = "Monday"
  hour  = 8
  minute = 0
}
```

Start and stop schedules can be configured independently.

## Disabling/Enabling Scheduling

You can temporarily disable scheduling for maintenance or holidays:

```hcl
enabled_start = false  # Disable start scheduling
enabled_stop  = true   # Keep stop scheduling enabled
```

## Permissions Required

- **Terraform User**: Must have permissions to create Logic Apps, deploy ARM templates, assign roles, create custom roles, and read AKS clusters in the subscription.
- **Logic App MSI**: Automatically assigned a custom "AKS StartStop Operator" role on each AKS cluster's resource group.
- **AKS Start/Stop**: The custom role includes only the necessary permissions:
  - `Microsoft.ContainerService/managedClusters/start/action`
  - `Microsoft.ContainerService/managedClusters/stop/action`

## Examples

See the [`examples/basic/`](examples/basic/) directory for complete usage examples:

- [`examples/basic/main.tf`](examples/basic/main.tf): Shows how to call the module with multiple clusters
- [`examples/basic/terraform.tfvars.example`](examples/basic/terraform.tfvars.example): Example input variables (copy to `terraform.tfvars` if running the module directly)

## Cleanup

To remove all resources:
```bash
terraform destroy
```

Note: This will delete the Logic Apps and remove the role assignments, but the AKS clusters themselves will remain.