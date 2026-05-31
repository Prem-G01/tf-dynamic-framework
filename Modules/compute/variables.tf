
variable "instance_name" {}
variable "zone" {}
variable "machine_type" {}
variable "os_image" {}
variable "disk_size" {}
variable "subnet" {}

variable "labels" {

  type = map(string)
}

variable "tags" {

  type = list(string)
}
