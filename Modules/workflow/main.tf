resource "google_workflows_workflow" "workflow" {

  for_each = var.workflows

  name     = each.value.workflow_name

  region   = each.value.region

  description = each.value.description

  service_account = "${each.value.service_account}@${var.project_id}.iam.gserviceaccount.com"

  source_contents = <<EOF

main:

  steps:

    - init:

        assign:

          - message: "Workflow Started"

    - finish:

        return: $${message}

EOF
}