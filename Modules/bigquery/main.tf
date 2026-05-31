resource "google_bigquery_dataset" "datasets" {

  for_each = var.datasets

  project                     = var.project_id
  dataset_id                  = each.value.dataset_id
  location                    = each.value.location
  description                 = each.value.description
  delete_contents_on_destroy  = each.value.delete_contents_on_destroy
}

resource "google_bigquery_table" "tables" {

  for_each = var.tables

  dataset_id = each.value.dataset_id
  table_id   = each.value.table_id

  deletion_protection = false

  depends_on = [
    google_bigquery_dataset.datasets
  ]
}