variable "environment" {
  default = "dev"
}

variable "s3_bucket_name" {}

variable "mongodb_user" {
  description = "The username for MongoDB connection"
  type        = string
  sensitive   = true
}

variable "mongodb_password" {
  description = "The password for MongoDB connection"
  type        = string
  sensitive   = true
}

variable "mongodb_host" {
  description = "The host for MongoDB connection"
  type        = string
}

variable "mongodb_database" {
  description = "The database for MongoDB connection"
  type        = string
}
