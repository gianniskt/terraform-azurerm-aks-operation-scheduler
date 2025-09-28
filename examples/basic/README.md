# Basic Example

This example demonstrates how to use the `terraform-azurerm-aks-operation-scheduler` module to schedule start and stop operations for AKS clusters.

## Usage

1. Update the `main.tf` file with your cluster details and desired schedules.
2. Run `terraform init`, `terraform plan`, and `terraform apply`.

## Requirements

- Azure subscription with existing AKS clusters
- Permissions to create Logic Apps and assign roles
- Terraform >= 1.0

## Files

- **`main.tf`**: Shows how to call the module with inline cluster configurations
- **`terraform.tfvars.example`**: Example input variables if you want to run the module directly (not as a submodule)

## Configuration

This example shows:
- **Module Call**: How to reference and configure the module in your Terraform code
- **Multiple Clusters**: Support for scheduling multiple AKS clusters with different schedules
- **Flexible Schedules**: Both weekly and monthly scheduling options
- **Independent Control**: Enable/disable start and stop operations separately

The example includes:
- A weekday cluster (Monday-Friday, 8 AM - 6 PM)
- A weekend cluster (Saturday-Sunday, 9:30 AM - 10 PM)