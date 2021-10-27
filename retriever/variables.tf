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
  sensitive   = true
  default     = ""
}

variable "mongodb_personal_host" {
  description = "The personal host for MongoDB connection"
  type        = string
  sensitive   = true
  default     = ""
}

variable "mongodb_database" {
  description = "The database for MongoDB connection"
  type        = string
  sensitive   = true
}

variable "mongodb_analysis_results_collection" {
  description = "The collection for querying analysis results in MongoDB"
  type        = string
}

variable "redis_host" {
  description = "The host for Redis connection"
  sensitive   = true
  default     = ""
}

variable "redis_personal_host" {
  description = "The personal host for Redis connection"
  type        = string
  sensitive   = true
  default     = ""
}

variable "redis_port" {
  description = "The port for Redis connection"
  type        = string
  sensitive   = true
  default     = 6379
}

variable "redis_user" {
  description = "The username for Redis connection"
  type        = string
  sensitive   = true
}

variable "redis_password" {
  description = "The password for Redis connection"
  type        = string
  sensitive   = true
}
