variable "project_id" {
  type = string
}

variable "datasets" {
  type = map(object({
    dataset_id                 = string
    location                   = string
    description                = string
    delete_contents_on_destroy = bool
  }))
}

variable "tables" {
  type = map(object({
    dataset_id = string
    table_id   = string
  }))
}