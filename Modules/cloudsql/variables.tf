variable "instance_name" {}
variable "region" {}
variable "db_version" {}
variable "tier" {}
variable "disk_size" {}
variable "db_password" {}
variable "network" {}
variable "labels" {

  type = map(string)
}