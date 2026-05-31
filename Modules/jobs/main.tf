resource "google_cloud_scheduler_job" "job" {

  name = var.job_name

  region = var.region

  schedule = var.schedule

  time_zone = "Asia/Kolkata"

  http_target {

    uri = "https://www.googleapis.com"

    http_method = "GET"
  }
}