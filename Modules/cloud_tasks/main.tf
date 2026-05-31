resource "google_cloud_tasks_queue" "queue" {
  name     = var.queue_name
  location = var.region
}