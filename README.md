# Terraform AzureRM AKS Operation Scheduler

[![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=flat&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/Azure-%230072C6.svg?style=flat&logo=microsoftazure&logoColor=white)](https://azure.microsoft.com/)
[![Terraform Registry](https://img.shields.io/badge/Terraform%20Registry-Published-623CE4?logo=terraform)](https://registry.terraform.io/modules/gianniskt/aks-operation-scheduler/azurerm)

This Terraform module provisions Azure Logic Apps Consumption workflows to automatically start and stop AKS clusters on customizable schedules (weekly or monthly).

## Features

- 🕐 **Flexible Scheduling**: Weekly or monthly schedules with customizable start/stop times
- 💰 **Cost Optimization**: Automatically stop AKS clusters during off-hours (save ~$73/month per cluster)
- 🔒 **Least-Privilege Security**: Custom IAM role with only start/stop permissions
- 📊 **Azure Logic Apps**: Serverless scheduling with built-in monitoring
- 🎯 **Multi-Cluster Support**: Manage multiple AKS clusters with different schedules
- 🔄 **Independent Control**: Enable/disable start and stop operations separately

## Architecture

The solution uses Azure Logic Apps Consumption to schedule start and stop operations for AKS clusters. For each cluster defined in the `clusters` variable, two workflows are created:
- One for **starting** the cluster based on the specified schedule and start time
- One for **stopping** the cluster based on the specified schedule and stop time

Each workflow uses a Recurrence trigger to run on the defined days at the specified UTC time, and an "Invoke Resource Action" to call the Azure Resource Manager API to start or stop the AKS cluster.

The Logic Apps are assigned system-managed identities with a custom "AKS StartStop Operator" role on the respective AKS clusters to perform the operations.

The workflows are deployed using ARM templates via Terraform's `azurerm_resource_group_template_deployment` for full automation.

### Important: Cost Savings

**Unlike AWS EKS**, Azure AKS control plane can be **completely stopped** at no cost. This module provides significant savings:
- ✅ Stop entire AKS cluster (control plane + nodes)
- ✅ No charges when stopped ($0/hour)
- 💰 Save ~$73/month per Standard cluster (8hrs/day, 5 days/week)

## Usage

### Basic Example

```hcl
module "aks_scheduler" {
  source  = "gianniskt/aks-operation-scheduler/azurerm"
  version = "~> 1.0"

  clusters = {
    my-cluster = {
      resource_group  = "my-resource-group"
      location        = "eastus"
      subscription_id = "00000000-0000-0000-0000-000000000000"
      cluster_name    = "my-aks-cluster"
      
      start_schedule = {
        type   = "weekly"
        days   = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
        hour   = 8
        minute = 0
      }
      
      stop_schedule = {
        type   = "weekly"
        days   = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
        hour   = 18
        minute = 0
      }
      
      enabled_start = true
      enabled_stop  = true
    }
  }
}
```

### Multiple Clusters Example

```hcl
module "aks_scheduler" {
  source  = "gianniskt/aks-operation-scheduler/azurerm"
  version = "~> 1.0"

  clusters = {
    dev-cluster = {
      resource_group  = "dev-rg"
      location        = "eastus"
      subscription_id = "00000000-0000-0000-0000-000000000000"
      cluster_name    = "dev-aks-cluster"
      start_schedule = {
        type   = "weekly"
        days   = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
        hour   = 8
        minute = 0
      }
      stop_schedule = {
        type   = "weekly"
        days   = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
        hour   = 18
        minute = 0
      }
    }
    
    staging-cluster = {
      resource_group  = "staging-rg"
      location        = "westeurope"
      subscription_id = "00000000-0000-0000-0000-000000000000"
      cluster_name    = "staging-aks-cluster"
      start_schedule = {
        type   = "monthly"
        week   = 1
        day    = "Monday"
        hour   = 9
        minute = 0
      }
      stop_schedule = {
        type   = "monthly"
        week   = 1
        day    = "Friday"
        hour   = 17
        minute = 0
      }
    }
  }
}
```

## Requirements

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>3.0 |

## Providers

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.56.0 |

## Inputs

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_clusters"></a> [clusters](#input\_clusters) | Map of clusters with their configs | <pre>map(object({<br/>    resource_group  = string<br/>    location        = string<br/>    subscription_id = string<br/>    cluster_name    = string<br/>    start_schedule = object({<br/>      type   = optional(string, "weekly")<br/>      days   = optional(list(string), [])<br/>      week   = optional(number, null)<br/>      day    = optional(string, null)<br/>      hour   = number<br/>      minute = number<br/>    })<br/>    stop_schedule = object({<br/>      type   = optional(string, "weekly")<br/>      days   = optional(list(string), [])<br/>      week   = optional(number, null)<br/>      day    = optional(string, null)<br/>      hour   = number<br/>      minute = number<br/>    })<br/>    enabled_start = optional(bool, true)<br/>    enabled_stop  = optional(bool, true)<br/>  }))</pre> | n/a | yes |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arm_template_deployment_ids"></a> [arm\_template\_deployment\_ids](#output\_arm\_template\_deployment\_ids) | IDs of the ARM template deployments |
| <a name="output_logic_app_workflow_ids"></a> [logic\_app\_workflow\_ids](#output\_logic\_app\_workflow\_ids) | IDs of the created Logic App workflows |
| <a name="output_logic_app_workflow_names"></a> [logic\_app\_workflow\_names](#output\_logic\_app\_workflow\_names) | Names of the created Logic App workflows |
| <a name="output_role_assignments"></a> [role\_assignments](#output\_role\_assignments) | Role assignments for the Logic Apps |
| <a name="output_role_definition_ids"></a> [role\_definition\_ids](#output\_role\_definition\_ids) | IDs of the custom role definitions created |

## Schedule Configuration

### Weekly Schedules

Specify `type = "weekly"` and a list of `days`:

```hcl
start_schedule = {
  type   = "weekly"
  days   = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
  hour   = 8   # UTC
  minute = 0
}
```

**Recurrence Pattern**: Runs on specified days at the given time (UTC)

### Monthly Schedules

Specify `type = "monthly"`, `week` (1-4, or -1 for last), and `day`:

```hcl
start_schedule = {
  type   = "monthly"
  week   = 1          # 1st occurrence
  day    = "Monday"   # Day of week
  hour   = 8
  minute = 0
}
```

**Recurrence Pattern**: Runs on the 1st Monday of each month at 08:00 UTC

### Disabling Schedules

You can temporarily disable scheduling for maintenance:

```hcl
enabled_start = false  # Disable start scheduling
enabled_stop  = true   # Keep stop scheduling enabled
```

## How It Works

1. **Recurrence Trigger** fires at the specified schedule (UTC timezone)
2. **Logic App** is triggered with cluster context
3. Logic App calls **Azure Resource Manager API** to start/stop the AKS cluster
4. **System-Managed Identity** authenticates with custom "AKS StartStop Operator" role
5. **AKS cluster** starts or stops (including control plane and all nodes)
6. Operation completes (typically 3-5 minutes)

## Monitoring

### Azure Portal

View Logic App run history in Azure Portal:
1. Navigate to the Logic App (e.g., `logicapp-{cluster-key}-start`)
2. Click "Run history" to see execution status
3. Click individual runs to see detailed execution logs

### Azure CLI

Check Logic App workflow runs:

```bash
az logicapp workflow show \
  --resource-group <resource-group> \
  --name logicapp-<cluster-key>-start \
  --query "state"
```

### Manual Testing

Trigger Logic App manually:

```bash
az rest \
  --method POST \
  --uri "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.Logic/workflows/logicapp-<cluster-key>-start/triggers/manual/run?api-version=2019-05-01"
```

### Check AKS Cluster Status

```bash
az aks show \
  --resource-group <resource-group> \
  --name <cluster-name> \
  --query "powerState.code"
```

## Cost Estimation

### Monthly Costs (Example: 1 AKS Cluster)

| Component | Cost |
|-----------|------|
| **AKS Standard (stopped)** | **$0.00** (no charges when stopped) |
| Logic Apps Consumption | $0.20 (2 executions/day × 20 days × $0.000025) |
| ARM API Calls | Free (within Azure Resource Manager limits) |
| **Total (off-hours)** | **~$0.20/month** |

### Savings Calculation

- **Without Scheduler** (Standard AKS 24/7): ~$73/month
- **With Scheduler** (8hrs/day, 5 days/week): ~$14.60 (running) + $0.20 (Logic Apps) = ~$14.80/month
- **Monthly Savings**: ~$58 (~80% reduction)

## Limitations

- ⚠️ **AKS restart time** - Cluster takes 3-5 minutes to start (cold start)
- ⚠️ **No graceful shutdown** - Pods are terminated when cluster stops
- ⚠️ **UTC timezone only** - Logic Apps use UTC for scheduling
- ⚠️ **Stateful workloads** - Require special handling (persistent volumes, StatefulSets)
- ℹ️ **ARM template dependency** - Uses ARM templates for Logic Apps deployment

## Comparison with EKS Scheduler

| Feature | AKS Scheduler | EKS Scheduler |
|---------|---------------|---------------|
| **Control Plane Stop** | ✅ Yes ($0 when stopped) | ❌ No ($72/month always) |
| **Node Stop** | ✅ Yes | ✅ Yes |
| **Scheduler Service** | Azure Logic Apps | AWS Lambda + EventBridge |
| **Terraform Support** | ✅ Excellent | ✅ Excellent |
| **Cost Savings** | 70-90% | 40-60% |
| **Implementation** | ARM Template | Lambda Function |

## Troubleshooting

### Logic App Fails with "Unauthorized"

Ensure the Logic App's system-managed identity has the custom "AKS StartStop Operator" role assigned:

```bash
az role assignment list \
  --assignee <logic-app-principal-id> \
  --scope /subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.ContainerService/managedClusters/<cluster-name>
```

### Cluster Doesn't Start/Stop

Check:
- Logic App is enabled (`enabled_start = true` / `enabled_stop = true`)
- Logic App run history for errors
- AKS cluster status: `az aks show --resource-group <rg> --name <cluster> --query "powerState"`

### Schedule Not Triggering

- Logic Apps use **UTC timezone**
- Verify schedule in Azure Portal (Logic App Designer → Trigger settings)
- Check Logic App is not disabled

## Examples

See the [`examples/basic/`](examples/basic/) directory for complete usage examples:

- [`examples/basic/main.tf`](examples/basic/main.tf): Shows how to call the module with multiple clusters
- [`examples/basic/terraform.tfvars.example`](examples/basic/terraform.tfvars.example): Example input variables

## License

MIT License

## Contributing

Contributions welcome! Please open an issue or pull request.

## Related Projects

- [terraform-aws-eks-operation-scheduler](https://github.com/gianniskt/terraform-aws-eks-operation-scheduler) - EKS version of this module
- [Azure Logic Apps Documentation](https://docs.microsoft.com/en-us/azure/logic-apps/) - Official Azure Logic Apps documentation
- [AKS Documentation](https://docs.microsoft.com/en-us/azure/aks/) - Official AKS documentation