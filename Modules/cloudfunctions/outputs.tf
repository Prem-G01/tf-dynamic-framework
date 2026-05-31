output "function_names" {

  value = {

    for k,v in google_cloudfunctions2_function.functions :

    k => v.name
  }
}