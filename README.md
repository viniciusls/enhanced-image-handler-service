# enhanced-image-handler-service
![Travis (.com) branch](https://img.shields.io/travis/com/viniciusls/enhanced-image-handler-service/main)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/viniciusls/enhanced-image-handler-service)
![GitHub](https://img.shields.io/github/license/viniciusls/enhanced-image-handler-service)

An image uploader built on top of AWS - using Terraform - to analyze the content of uploaded images using 
Clarifai IA to predict the content and saving the results to database for further use. It also generates a thumbnail 
for each image and save it to S3.

## What's used in this project?
- **Terraform** to build Infrastructure as Code;
- **AWS API** Gateway to provide endpoints for image uploading and data retrieve;
- **AWS S3** to save the images and its generated thumbnails;
- **AWS Lambda** to handle the image upload notification from S3, to generate thumbnails and to integrate with Clarifai API
and save the results on MongoDB. Also to retrieve the results from Elasticache/MongoDB;
- **AWS SNS** to fan-out the uploaded image notification to SQS queues;
- **AWS SQS** to subscribe to SNS topic and call Lambdas to analyze images and generate thumbnails;
- **AWS ElastiCache/ElasticSearch** to cache search results;
- **MongoDB Atlas** hosted on AWS (shared) to save the analysis results;
- **Clarifai** to analyze images and predict what's inside them.

## Prerequisites
Here's the minimum requirements for running this project smoothly:
- [Terraform CLI](https://www.terraform.io/downloads.html)
- [AWS CLI](https://aws.amazon.com/pt/cli/)
- [AWS Free Tier Account](https://aws.amazon.com/pt/free/)
- [Clarifai Community Account](https://portal.clarifai.com/signup)
- [MongoDB Atlas Free Account](https://www.mongodb.com/cloud/atlas/register)

## How to install and deploy it?

1) Run `terraform init` to registry Terraform modules;
2) Install dependencies on the following directories:
```
cd ./analyzer
yarn install // or npm install

cd ./handler
yarn install // or npm install

cd ./thumbnailer
SHARP_IGNORE_GLOBAL_LIBVIPS=1 npm install --arch=x64 --platform=linux sharp 
// we have to run this custom command to avoid execution errors when running the Lambda. Ref: https://sharp.pixelplumbing.com/install#aws-lambda.
```
3) Add the following environment variables to your run config or use a `.tfvars` file:
```
TF_VAR_analyzer_clarifai_model_id=
TF_VAR_clarifai_api_key=
TF_VAR_mongodb_user=
TF_VAR_mongodb_password=
TF_VAR_mongodb_host=
TF_VAR_mongodb_database=
```
You can reach out [www.clarifai.com](https://www.clarifai.com) and create a free Community Account to get 
an API Key and find out the Clarifai Model ID that you want to use. You can also build a custom model and use it here!

Also, this project was built to support only MongoDB at the moment as a target for analysis results. Clarifai returns a 
JSON Array containing each object/food/person/etc inside the image sent for analysis and I thought it'd be a good idea to
use a Document-Oriented Database. You can create a free Shared-Host account at 
[www.mongodb.com/cloud/atlas](https://www.mongodb.com/cloud/atlas).
4) Setup [AWS CLI](https://aws.amazon.com/pt/cli/) with your credentials or use environment variables to setup your Access Key - Remember that it needs to have 
enough permission to setup your Cloud environment using these services I've mentioned above. You can use a Free Tier account on 
AWS to run this project - it's totally enough as I'm using only the basics and in some cases these resources are free forever.
5) Run `terraform plan` and check if everything works.
6) Run `terraform apply`, approve the changes and check if everything works.
7) Go to your `AWS Console` and get the URL on `API Gateway` to upload your image.
8) Voi lá! If everything went well, you should see your image on S3 along with the thumbnail (in a separated folder in the same bucket 
called `/thumbnails`) and the analysis results on your MongoDB database (in a Collection called `documents`).

## Issues? Questions?
Feel free to reach me out using `Issues` tab here and also on [Twitter](https://twitter.com/iviniciusls). I'll be glad to help you :)

## Contribute
You are certainly welcome to contribute to this project and I'll be very happy to work with you!
