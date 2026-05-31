variable "router_name" {}
variable "network" {}
variable "region" {}
variable "labels" {

  type = map(string)
}
variable "tags" {

  type = list(string)
}