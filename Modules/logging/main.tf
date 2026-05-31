resource "google_logging_project_sink" "sink" {

  for_each = var.sinks

  project = var.project_id

  name = each.value.sink_name

  destination = each.value.destination

  filter = each.value.filter

  unique_writer_identity = true
}