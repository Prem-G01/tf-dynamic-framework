locals {

  monitoring_data = csvdecode(
    file("${path.root}/../Config/monitoring.csv")
  )
}

resource "google_monitoring_notification_channel" "email" {

  for_each = {
    for alert in local.monitoring_data :
    alert.alert_name => alert
  }

  display_name = each.value.alert_name

  type = "email"

  labels = {
    email_address = each.value.email
  }
}

resource "google_monitoring_alert_policy" "alerts" {

  for_each = {
    for alert in local.monitoring_data :
    alert.alert_name => alert
  }

  display_name = each.value.alert_name

  combiner = "OR"

  conditions {

    display_name = each.value.metric

    condition_threshold {

      filter = (
        each.value.metric == "cpu" ?
        "resource.type=\"gce_instance\" AND metric.type=\"compute.googleapis.com/instance/cpu/utilization\"" :

        each.value.metric == "memory" ?
        "resource.type=\"gce_instance\" AND metric.type=\"agent.googleapis.com/memory/percent_used\"" :

        each.value.metric == "disk" ?
        "resource.type=\"gce_instance\" AND metric.type=\"agent.googleapis.com/disk/percent_used\"" :

        each.value.metric == "error_rate" ?
        "resource.type=\"cloud_run_revision\" AND metric.type=\"run.googleapis.com/request_count\"" :

        "resource.type=\"gce_instance\" AND metric.type=\"compute.googleapis.com/instance/cpu/utilization\""
      )

      duration = each.value.duration

      comparison = "COMPARISON_GT"

      threshold_value = tonumber(each.value.threshold) / 100

      aggregations {

        alignment_period = "60s"

        per_series_aligner = "ALIGN_MEAN"
      }

      trigger {
        count = 1
      }
    }
  }

  notification_channels = [
    google_monitoring_notification_channel.email[
      each.key
    ].id
  ]

  enabled = true
}