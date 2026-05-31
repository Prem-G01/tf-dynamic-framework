locals {

  apis = csvdecode(
    file("${path.root}/../Config/apis.csv")
  )
}

resource "google_project_service" "apis" {

  for_each = {
    for api in local.apis :
    api.api => api
  }

  project = var.project_id

  service = each.value.api

  disable_on_destroy = false
}