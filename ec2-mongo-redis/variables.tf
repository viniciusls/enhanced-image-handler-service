variable "ami_id" {}
variable "vpc_id" {}
variable "private_subnet_ids" {}
variable "private_subnet_cidrs" {}

variable "key_name" {
  description = "The key name for Key/Pair auth"
  type        = string
  sensitive   = true
}
