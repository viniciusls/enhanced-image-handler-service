// dependencies
const AWS = require('aws-sdk');
const axios = require('axios');
const { MongoClient } = require("mongodb");
const util = require('util');

// get reference to S3 client
const s3 = new AWS.S3();

// mongoDB setup
const uri = `mongodb+srv://${process.env.MONGODB_USER}:${process.env.MONGODB_PASSWORD}@${process.env.MONGODB_HOST}/${process.env.MONGODB_DATABASE}?retryWrites=true&w=majority`;
const mongoClient = new MongoClient(uri);

exports.handler = async (event, context, callback) => {
  try {
    // Read options from the event parameter.
    console.log("Reading options from event:\n", util.inspect(event, {depth: 5}));
    const body = JSON.parse(event.Records[0].body);
    const srcBucket = body.BucketName;

    // Object key may have spaces or unicode non-ASCII characters.
    const srcKey = decodeURIComponent(body.ObjectKey.replace(/\+/g, " "));

    const origImage = await getObject(srcBucket, srcKey);

    const analysisResult = await getAnalysis(origImage.Body);

    console.log(analysisResult);

    await saveAnalysisResultToDatabase(srcBucket, srcKey, analysisResult);

    console.log(`Successfully analyzed ${srcBucket}/${srcKey}`);
  } catch (error) {
    console.log(error);
    return false;
  }
};

const getObject = async (srcBucket, srcKey) => {
  // Infer the image type from the file suffix.
  const typeMatch = srcKey.match(/\.([^.]*)$/);
  if (!typeMatch) {
    console.log("Could not determine the image type.");
    return;
  }

  // Check that the image type is supported
  const imageType = typeMatch[1].toLowerCase();
  if (imageType !== "jpeg" && imageType !== "jpg" && imageType !== "png") {
    console.log(`Unsupported image type: ${imageType}`);
    return;
  }

  // Download the image from the S3 source bucket.
  const params = {
    Bucket: srcBucket,
    Key: srcKey
  };

  return await s3.getObject(params).promise();
}

const getAnalysis = async (imageBuffer) => {
  const requestBody = JSON.stringify({
    "inputs": [
      {
        "data": {
          "image": {
            "base64": imageBuffer.toString('base64')
          }
        }
      }
    ]
  });

  const response = await axios.post(`https://api.clarifai.com/v2/models/${process.env.ANALYZER_CLARIFAI_MODEL_ID}/outputs`,
    requestBody,
    {
      headers: {
        'Accept': 'application/json',
        'Authorization': `Bearer ${process.env.CLARIFAI_API_KEY}`,
        'Content-Type': 'application/json'
      }
    }
  );

  return response.data?.outputs[0]?.data?.concepts;
}

const saveAnalysisResultToDatabase = async(objectBucket, objectKey, analysisResult) => {
  try {
    await mongoClient.connect();

    const database = mongoClient.db(process.env.MONGODB_DATABASE);
    const collection = database.collection(process.env.MONGODB_ANALYSIS_RESULTS_COLLECTION);

    const recordBody = formatRecord(objectBucket, objectKey, analysisResult);

    console.log(recordBody);

    return await collection.insertOne(recordBody);
  } finally {
    await mongoClient.close();
  }
}

const formatRecord = (objectBucket, objectKey, analysisResult) => {
  return Object.assign({ analysisResult }, { objectBucket, objectKey, createdAt: new Date().toISOString() });
}
