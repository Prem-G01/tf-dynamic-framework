variable "project_id" {
  type = string
}

variable "functions" {
  type = map(any)
}

variable "function_envs" {
  type = map(any)
}