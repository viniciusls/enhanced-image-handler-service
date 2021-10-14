// dependencies
const AWS = require('aws-sdk');
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
  if (imageType !== "jpg" && imageType !== "png") {
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
