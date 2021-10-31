variable "filename" {}
variable "function_name" {}
variable "iam_role_arn" {}
variable "handler" {}
variable "source_code_hash" {}
variable "runtime" {}
variable "timeout" {
  default = 60
}
variable "memory_size" {
  default = 1024
}
variable "environment_variables" {
  default = {}
}
