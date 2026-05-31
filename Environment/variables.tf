variable "project_id" {}
variable "region" {}
variable "environment" {}
variable "db_password" {

  sensitive = true
}