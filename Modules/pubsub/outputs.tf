output "topics" {

  value = {
    for k,v in google_pubsub_topic.topics :
    k => v.name
  }
}

output "subscriptions" {

  value = {
    for k,v in google_pubsub_subscription.subscriptions :
    k => v.name
  }
}