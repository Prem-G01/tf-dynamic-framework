output "trigger_names" {

  value = {

    for k,v in google_cloudbuild_trigger.triggers :

    k => v.name
  }
}