resource "google_cloudbuild_trigger" "triggers" {

  for_each = var.triggers

  project = var.project_id

  name        = each.value.trigger_name
  description = each.value.description

  github {

    owner = each.value.github_owner

    name  = each.value.repository_name

    push {

      branch = "^${each.value.branch}$"
    }
  }

  filename = each.value.filename
}