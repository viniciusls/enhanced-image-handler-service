# enhanced-image-handler-service
![Travis (.com) branch](https://img.shields.io/travis/com/viniciusls/enhanced-image-handler-service/main)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/viniciusls/enhanced-image-handler-service)
![GitHub](https://img.shields.io/github/license/viniciusls/enhanced-image-handler-service)

Simple AWS Lambda to generate thumbnails to AWS S3 from images uploaded to AWS S3 using Terraform

Before deploy it, run `SHARP_IGNORE_GLOBAL_LIBVIPS=1 npm install --arch=x64 --platform=linux sharp` if not using Linux. 

Ref: https://sharp.pixelplumbing.com/install#aws-lambda.
