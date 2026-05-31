output "workflow_names" {

  value = {

    for k,v in google_workflows_workflow.workflow :

    k => v.name
  }
}