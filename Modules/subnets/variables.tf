variable "subnet_name" {}
variable "subnet_region" {}
variable "subnet_cidr" {}
variable "network" {}
variable "project_id" {}
variable "labels" {

  type = map(string)
}
variable "tags" {

  type = list(string)
}