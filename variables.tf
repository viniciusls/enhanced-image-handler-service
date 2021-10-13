//----------------------------------------------------------------------
// Shared Variables
//----------------------------------------------------------------------
variable "region" {
  default = "sa-east-1"
}

variable "environment" {
  default = "dev"
}

variable "s3_bucket_images" {
  default = "enhanced-image-handler-service-bucket"
}

variable "sns_topic_images" {
  default = "enhanced-image-handler-service-topic"
}

//----------------------------------------------------------------------
// API Gateway Variables
//----------------------------------------------------------------------

variable "supported_binary_media_types" {
  description = "Supported file types"
  type        = list(string)

  # NOTE: application/octet-stream is the least specific MIME type. It basically just stores the bytes and assumes the consuming application will know what to do with them.
  # On testing it appears you dont need any of the content types below after application/octet-stream. After uploading a variety of different file types I was able to download them all and open
  # them up successfully. The only issue was when issuing a GET request in postman for a jpeg file it would display the encoded bytes instead of the image. However,
  # if you open the same jpeg file up on the desktop in an image-viewer there was no problem. The content types below after the application/octet-stream just assist some applications in opening
  # the files up. Also note there is a limit of 25 media types allowed in aws api gateway.
  default = [
    "application/octet-stream",
    "image/jpeg",
    "image/gif",
    "image/png",
    "image/bmp",
    "image/svg+xml",
    "image/tiff",
    "image/x-dcraw",                                                           # Digital raw image
  ]
}
