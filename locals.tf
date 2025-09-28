locals {
  clusters = var.clusters

  workflows = flatten([
    for cluster_key, cluster in local.clusters : [
      {
        cluster_key = cluster_key
        action      = "start"
        schedule    = cluster.start_schedule
        enabled     = cluster.enabled_start
        recurrence = cluster.start_schedule.type == "monthly" ? {
          frequency = "Month"
          interval  = 1
          schedule = merge({
            weekDays = [cluster.start_schedule.day]
            hours    = [cluster.start_schedule.hour]
            minutes  = [cluster.start_schedule.minute]
          }, cluster.start_schedule.week != null ? { week = cluster.start_schedule.week } : {})
          timeZone = "UTC"
          } : {
          frequency = "Week"
          interval  = 1
          schedule = {
            weekDays = cluster.start_schedule.days
            hours    = [cluster.start_schedule.hour]
            minutes  = [cluster.start_schedule.minute]
          }
          timeZone = "UTC"
        }
      },
      {
        cluster_key = cluster_key
        action      = "stop"
        schedule    = cluster.stop_schedule
        enabled     = cluster.enabled_stop
        recurrence = cluster.stop_schedule.type == "monthly" ? {
          frequency = "Month"
          interval  = 1
          schedule = merge({
            weekDays = [cluster.stop_schedule.day]
            hours    = [cluster.stop_schedule.hour]
            minutes  = [cluster.stop_schedule.minute]
          }, cluster.stop_schedule.week != null ? { week = cluster.stop_schedule.week } : {})
          timeZone = "UTC"
          } : {
          frequency = "Week"
          interval  = 1
          schedule = {
            weekDays = cluster.stop_schedule.days
            hours    = [cluster.stop_schedule.hour]
            minutes  = [cluster.stop_schedule.minute]
          }
          timeZone = "UTC"
        }
      }
    ]
  ])
}