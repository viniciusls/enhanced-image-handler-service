variable "ami_id" {}
variable "vpc_id" {}

variable "key_name" {
  description = "The key name for Key/Pair auth"
  type        = string
  sensitive   = true
}
