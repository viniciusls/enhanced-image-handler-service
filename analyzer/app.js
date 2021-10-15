// dependencies
const AWS = require('aws-sdk');
const axios = require('axios');
const util = require('util');

// get reference to S3 client
const s3 = new AWS.S3();

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
