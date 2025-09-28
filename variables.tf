variable "clusters" {
  description = "Map of clusters with their configs"
  type = map(object({
    resource_group  = string
    location        = string
    subscription_id = string
    cluster_name    = string
    start_schedule = object({
      type   = optional(string, "weekly")
      days   = optional(list(string), [])
      week   = optional(number, null)
      day    = optional(string, null)
      hour   = number
      minute = number
    })
    stop_schedule = object({
      type   = optional(string, "weekly")
      days   = optional(list(string), [])
      week   = optional(number, null)
      day    = optional(string, null)
      hour   = number
      minute = number
    })
    enabled_start = optional(bool, true)
    enabled_stop  = optional(bool, true)
  }))
}