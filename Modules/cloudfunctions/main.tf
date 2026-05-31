resource "google_cloudfunctions2_function" "functions" {

  depends_on = [
    google_storage_bucket_object.function_zip
  ]

  for_each = var.functions

  name        = each.value.function_name
  location    = each.value.region
  description = each.value.description

  build_config {

    runtime     = each.value.runtime
    entry_point = each.value.entry_point

    source {

      storage_source {

        bucket = each.value.source_bucket
        object = google_storage_bucket_object.function_zip[each.key].name
      }
    }
  }

  service_config {

    max_instance_count = each.value.max_instances

    min_instance_count = each.value.min_instances

    available_memory = "${each.value.memory_mb}M"

    timeout_seconds = each.value.timeout_seconds

    service_account_email = "${each.value.service_account}@${var.project_id}.iam.gserviceaccount.com"

    environment_variables = lookup(
      var.function_envs,
      each.value.function_name,
      {}
    )
  }
}

resource "google_cloudfunctions2_function_iam_member" "invoker" {

  for_each = var.functions

  project        = var.project_id
  location       = each.value.region
  cloud_function = google_cloudfunctions2_function.functions[each.key].name

  role = "roles/cloudfunctions.invoker"

  member = "serviceAccount:${each.value.service_account}@${var.project_id}.iam.gserviceaccount.com"
}