
locals {

  compute_data    = csvdecode(file("${path.root}/../Config/compute.csv"))
  cloudsql_data   = csvdecode(file("${path.root}/../Config/cloudsql.csv"))
  cloudrun_data   = csvdecode(file("${path.root}/../Config/cloudrun.csv"))
  bucket_data     = csvdecode(file("${path.root}/../Config/buckets.csv"))
  secrets_data    = csvdecode(file("${path.root}/../Config/secrets.csv"))
  cloudtasks_data = csvdecode(file("${path.root}/../Config/cloudtasks.csv"))

  ############################################
  # ENTERPRISE LABELS
  ############################################

  labels_data = csvdecode(
    file("${path.root}/../Config/labels.csv")
  )

  common_labels = {
    for item in local.labels_data :
    item.key => item.value
  }

  ############################################
  # ENTERPRISE TAGS
  ############################################

  tags_data = csvdecode(
    file("${path.root}/../Config/tags.csv")
  )

  common_tags = [
    for item in local.tags_data :
    item.tag
  ]
}

locals {

  bigquery_dataset_data = {
    for row in csvdecode(
      file("${path.root}/../Config/bigquery_datasets.csv")
    ) :
    row.dataset_id => {
      dataset_id                 = row.dataset_id
      location                   = row.location
      description                = row.description
      delete_contents_on_destroy = lower(row.delete_contents_on_destroy) == "true"
    }
  }

  bigquery_table_data = {
    for idx, row in csvdecode(
      file("${path.root}/../Config/bigquery_tables.csv")
    ) :
    "${row.dataset_id}-${row.table_id}" => {
      dataset_id = row.dataset_id
      table_id   = row.table_id
    }
  }
}

locals {

  cloudfunction_data = {

    for row in csvdecode(
      file("${path.root}/../Config/cloudfunctions.csv")
    ) :

    row.function_name => {

      function_name = row.function_name
      description   = row.description
      region        = row.region
      runtime       = row.runtime

      memory_mb       = tonumber(row.memory_mb)
      timeout_seconds = tonumber(row.timeout_seconds)

      min_instances = tonumber(row.min_instances)
      max_instances = tonumber(row.max_instances)

      entry_point = row.entry_point

      source_bucket = row.source_bucket
      source_object = row.source_object

      service_account = row.service_account

      trigger_type  = row.trigger_type
      trigger_topic = row.trigger_topic
    }
  }
}

locals {

  function_env_data = {

    for function_name in distinct([
      for row in csvdecode(
        file("${path.root}/../Config/function_env.csv")
      ) :
      row.function_name
    ]) :

    function_name => {

      for row in csvdecode(
        file("${path.root}/../Config/function_env.csv")
      ) :

      row.key => row.value

      if row.function_name == function_name
    }
  }
}

locals {

  pubsub_topics = {

    for row in csvdecode(
      file("${path.root}/../Config/pubsub_topics.csv")
    ) :

    row.topic_name => {

      topic_name = row.topic_name

      message_retention_duration = row.message_retention_duration

      labels = row.labels
    }
  }
}

locals {

  pubsub_subscriptions = {

    for row in csvdecode(
      file("${path.root}/../Config/pubsub_subscriptions.csv")
    ) :

    row.subscription_name => {

      subscription_name = row.subscription_name

      topic_name = row.topic_name

      ack_deadline_seconds = tonumber(row.ack_deadline_seconds)

      message_retention_duration = row.message_retention_duration
    }
  }
}

locals {

  cloudbuild_triggers = {

    for row in csvdecode(
      file("${path.root}/../Config/cloudbuild_triggers.csv")
    ) :

    row.trigger_name => {

      trigger_name = row.trigger_name

      description = row.description

      repository_name = row.repository_name

      branch = row.branch

      filename = row.filename

      service_account = row.service_account

      github_owner = "your-github-org"
    }
  }
}

locals {

  logging_sinks = {

    for row in csvdecode(
      file("${path.root}/../Config/logging.csv")
    ) :

    row.sink_name => {

      sink_name = row.sink_name

      destination = row.destination_name

      filter = row.filter

      destination_type = row.destination_type
    }
  }
}

locals {

  iam_bindings = {

    for idx, row in csvdecode(
      file("${path.root}/../Config/iam_bindings.csv")
    ) :

    "${row.member}-${row.role}" => {

      member = row.member

      role = row.role
    }
  }
}

locals {

  workflow_data = {

    for row in csvdecode(
      file("${path.root}/../Config/workflows.csv")
    ) :

    row.workflow_name => {

      workflow_name = row.workflow_name

      region = row.region

      description = row.description

      service_account = row.service_account
    }
  }
}

locals {
  service_account_data = [

    for row in csvdecode(
      file("${path.root}/../Config/service_accounts.csv")
      ) : {

      account_id   = row.account_id
      display_name = row.display_name
    }
  ]
}