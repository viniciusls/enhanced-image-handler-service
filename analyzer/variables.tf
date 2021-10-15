variable "clarifai_api_key" {
  description = "The API Key for Clarifai"
  type        = string
  sensitive   = true
}

variable "analyzer_clarifai_model_id" {
  description = "The Model ID for the analyzer use within Clarifai"
  type        = string
}

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
