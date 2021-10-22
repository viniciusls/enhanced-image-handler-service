//----------------------------------------------------------------------
// Shared Variables
//----------------------------------------------------------------------
variable "region" {
  default = "sa-east-1"
}

variable "environment" {
  default = "dev"
}

variable "s3_bucket_name" {
  default = "enhanced-image-handler-service-bucket"
}

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
  sensitive   = true
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
