output "dataset_ids" {
  value = {
    for k, v in google_bigquery_dataset.datasets :
    k => v.dataset_id
  }
}

output "table_ids" {
  value = {
    for k, v in google_bigquery_table.tables :
    k => v.table_id
  }
}