resource "google_pubsub_topic" "topics" {

  for_each = var.topics

  project = var.project_id
  name    = each.value.topic_name

  message_retention_duration = each.value.message_retention_duration

  labels = {
    application = each.value.labels
  }
}

resource "google_pubsub_subscription" "subscriptions" {

  for_each = var.subscriptions

  project = var.project_id

  name  = each.value.subscription_name
  topic = google_pubsub_topic.topics[
    each.value.topic_name
  ].name

  ack_deadline_seconds = each.value.ack_deadline_seconds

  message_retention_duration = each.value.message_retention_duration

  depends_on = [
    google_pubsub_topic.topics
  ]
}