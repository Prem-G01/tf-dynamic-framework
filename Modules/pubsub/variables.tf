variable "project_id" {
  type = string
}

variable "topics" {
  type = map(any)
}

variable "subscriptions" {
  type = map(any)
}