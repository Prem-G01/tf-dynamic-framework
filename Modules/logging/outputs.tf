output "sink_names" {

  value = {

    for k,v in google_logging_project_sink.sink :

    k => v.name
  }
}