variable "firewall_name" {}

variable "network" {}

variable "protocol" {}

variable "ports" {

  type = list(string)
}

variable "source_ranges" {

  type = list(string)
}
variable "tags" {

  type = list(string)
}