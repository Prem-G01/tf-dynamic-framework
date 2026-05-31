############################################
# VPC
############################################

module "vpc" {

  source = "../Modules/vpc"

  project_id   = var.project_id
  network_name = "vpc-${var.environment}"
  tags         = local.common_tags
}

############################################
# PRIVATE SERVICE ACCESS
############################################

module "private_service_access" {

  source = "../Modules/private_service_access"

  network = module.vpc.network_id
}

############################################
# SUBNETS
############################################

module "subnets" {

  source = "../Modules/subnets"

  project_id = var.project_id

  for_each = {
    for subnet in csvdecode(file("${path.root}/../Config/subnets.csv")) :
    subnet.subnet_name => subnet
  }

  subnet_name   = each.value.subnet_name
  subnet_region = each.value.region
  subnet_cidr   = each.value.cidr
  network       = module.vpc.network_name
  labels        = local.common_labels
  tags          = local.common_tags
}

############################################
# FIREWALL
############################################

module "firewall" {

  source = "../Modules/firewall"

  for_each = {
    for fw in csvdecode(file("${path.root}/../Config/firewall.csv")) :
    fw.rule_name => fw
  }

  firewall_name = each.value.rule_name
  network       = module.vpc.network_name
  protocol      = each.value.protocol

  ports = split(",", each.value.ports)

  source_ranges = split(",", each.value.source_ranges)

  tags = local.common_tags
}

############################################
# ROUTER
############################################

module "router" {

  source = "../Modules/router"

  router_name = "router-${var.environment}"

  network = module.vpc.network_name

  region = var.region

  labels = local.common_labels

  tags = local.common_tags
}

############################################
# CLOUD NAT
############################################

module "cloud_nat" {

  source = "../Modules/cloud_nat"

  nat_name = "nat-${var.environment}"

  router_name = module.router.router_name

  region = var.region

  labels = local.common_labels

  tags = local.common_tags
}

############################################
# SERVICE ACCOUNT
############################################

module "service_accounts" {

  source = "../Modules/service_accounts"

  for_each = {
    for sa in local.service_account_data :
    sa.account_id => sa
  }

  project_id   = var.project_id
  account_id   = each.value.account_id
  display_name = each.value.display_name

}

############################################
# APIS
############################################

module "apis" {

  source = "../Modules/apis"

  project_id = var.project_id
}

############################################
# COMPUTE
############################################

module "compute" {

  source = "../Modules/compute"

  for_each = {
    for vm in local.compute_data :
    vm.instance_name => vm
  }

  instance_name = each.value.instance_name
  zone          = each.value.zone
  machine_type  = each.value.machine_type
  os_image      = each.value.image
  disk_size     = tonumber(each.value.disk_size)
  subnet        = module.subnets[each.value.subnet].subnet_name
  labels        = local.common_labels
  tags          = local.common_tags
}

############################################
# CLOUD SQL
############################################

module "cloudsql" {

  source = "../Modules/cloudsql"

  for_each = {
    for db in local.cloudsql_data :
    db.instance_name => db
  }

  instance_name = each.value.instance_name
  region        = var.region
  db_version    = each.value.database_version
  tier          = each.value.tier
  disk_size     = tonumber(each.value.disk_size)

  db_password = var.db_password

  network = module.vpc.network_id
  labels  = local.common_labels
  depends_on = [
    module.private_service_access
  ]
}

############################################
# STORAGE
############################################

module "storage" {

  source = "../Modules/storage"

  for_each = {
    for bucket in local.bucket_data :
    bucket.bucket_name => bucket
  }

  bucket_name   = each.value.bucket_name
  location      = each.value.location
  storage_class = each.value.storage_class
  labels        = local.common_labels
}

############################################
# ARTIFACT REGISTRY
############################################

module "artifact_registry" {

  source = "../Modules/artifact_registry"

  repository_id = "docker-repo"

  region = var.region
  labels = local.common_labels
}

############################################
# CLOUD RUN
############################################

module "cloudrun" {

  source = "../Modules/cloudrun"

  for_each = {
    for cr in local.cloudrun_data :
    cr.service_name => cr
  }

  service_name    = each.value.service_name
  region          = each.value.region
  container_image = each.value.image
  labels          = local.common_labels
  depends_on = [
    module.artifact_registry
  ]
}

############################################
# SECRETS
############################################

module "secrets" {

  source = "../Modules/secrets"

  for_each = {
    for secret in local.secrets_data :
    secret.secret_id => secret
  }

  secret_name  = each.value.secret_id
  secret_value = each.value.secret_value
}

############################################
# CLOUD TASKS
############################################

module "cloud_tasks" {

  source = "../Modules/cloud_tasks"

  for_each = {
    for queue in local.cloudtasks_data :
    queue.queue_name => queue
  }

  queue_name = each.value.queue_name
  region     = each.value.region
}

############################################
# JOBS
############################################

module "jobs" {

  source = "../Modules/jobs"

  for_each = {
    for job in csvdecode(file("${path.root}/../Config/jobs.csv")) :
    job.job_name => job
  }

  job_name = each.value.job_name

  schedule = each.value.schedule

  region = var.region

  depends_on = [
    module.apis
  ]
}

############################################
# WAF
############################################

module "waf" {

  source = "../Modules/waf"

  policy_name = "waf-policy-${var.environment}"
  tags        = local.common_tags
}

############################################
# MONITORING
############################################

module "monitoring_enterprise" {

  source = "../Modules/monitoring_enterprise"
}

############################################
# ENTERPRISE INVENTORY REPORT
############################################

resource "null_resource" "inventory_report" {

  provisioner "local-exec" {

    command = "powershell -ExecutionPolicy Bypass -File ../Scripts/inventory.ps1"
  }

  depends_on = [

    ############################################
    # CORE NETWORK
    ############################################

    module.vpc,
    module.private_service_access,
    module.subnets,

    ############################################
    # SECURITY
    ############################################

    module.firewall,
    module.waf,
    module.secrets,
    module.service_accounts,

    ############################################
    # NETWORK SERVICES
    ############################################

    module.router,
    module.cloud_nat,

    ############################################
    # COMPUTE
    ############################################

    module.compute,

    ############################################
    # DATABASE
    ############################################

    module.cloudsql,

    ############################################
    # STORAGE
    ############################################

    module.storage,

    ############################################
    # CONTAINERS
    ############################################

    module.artifact_registry,
    module.cloudrun,

    ############################################
    # TASKS / JOBS
    ############################################

    module.cloud_tasks,
    module.jobs,

    ############################################
    # APIs
    ############################################

    module.apis,

    ############################################
    # MONITORING
    ############################################

    module.monitoring_enterprise
  ]
}

############################################
# Bigquery
############################################

module "bigquery" {

  source = "../Modules/bigquery"

  project_id = var.project_id

  datasets = local.bigquery_dataset_data
  tables   = local.bigquery_table_data
}

############################################
# cloudfunctions
############################################

module "cloudfunctions" {

  source = "../Modules/cloudfunctions"

  project_id = var.project_id

  functions = local.cloudfunction_data

  function_envs = local.function_env_data


}

############################################
# Pubsub
############################################

module "pubsub" {

  source = "../Modules/pubsub"

  project_id = var.project_id

  topics = local.pubsub_topics

  subscriptions = local.pubsub_subscriptions
}

############################################
# Workflow
############################################

module "workflow" {

  source = "../Modules/workflow"

  project_id = var.project_id

  workflows = local.workflow_data
}

############################################
# Cloudbuild
############################################

module "cloudbuild" {

  source = "../Modules/cloudbuild"

  project_id = var.project_id

  triggers = local.cloudbuild_triggers
}

############################################
# Logging
############################################

module "logging" {

  source = "../Modules/logging"

  project_id = var.project_id

  sinks = local.logging_sinks
}

module "iam" {

  source = "../Modules/iam"

  project_id = var.project_id

  iam_bindings = local.iam_bindings
}