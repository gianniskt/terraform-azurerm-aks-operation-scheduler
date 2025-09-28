module "aks_operation_scheduler" {
  source = "../.."

  clusters = {
    example-cluster = {
      resource_group  = "ExampleRG"
      location        = "eastus"
      subscription_id = "12345678-1234-1234-1234-123456789012"
      cluster_name    = "example-aks"
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

    # Example of weekend scheduling
    weekend-cluster = {
      resource_group  = "WeekendRG"
      location        = "eastus"
      subscription_id = "12345678-1234-1234-1234-123456789012"
      cluster_name    = "weekend-aks"
      start_schedule = {
        type   = "weekly"
        days   = ["Saturday", "Sunday"]
        hour   = 9
        minute = 30
      }
      stop_schedule = {
        type   = "weekly"
        days   = ["Saturday", "Sunday"]
        hour   = 22
        minute = 0
      }
      enabled_start = true
      enabled_stop  = true
    }
  }
}