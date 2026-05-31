variable "nat_name" {}
variable "router_name" {}
variable "region" {}
variable "labels" {

  type = map(string)
}
variable "tags" {

  type = list(string)
}