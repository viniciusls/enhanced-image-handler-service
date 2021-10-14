// dependencies
const AWS = require('aws-sdk');
const util = require('util');
const sharp = require('sharp');

// get reference to S3 client
const s3 = new AWS.S3();

exports.handler = async (event, context, callback) => {
  try {
    // Read options from the event parameter.
    console.log("Reading options from event:\n", util.inspect(event, {depth: 5}));
    const srcBucket = event.Records[0].body.BucketName;

    // Object key may have spaces or unicode non-ASCII characters.
    const srcKey = decodeURIComponent(event.Records[0].body.ObjectKey.replace(/\+/g, " "));

    const dstBucket = `${srcBucket}/thumbnails`;
    const dstKey = `${srcKey.split('/').pop()}`;

    const origImage = await getObject(srcBucket, srcKey);
    const bufferThumbnail = await generateThumbnail(origImage);
    await publishThumbnailToS3(dstBucket, dstKey, bufferThumbnail);

    console.log(`Successfully resized ${srcBucket}/${srcKey} and uploaded to ${dstBucket}/${dstKey}`);
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

const generateThumbnail = async (origImage) => {
  // set thumbnail width. Resize will set the height automatically to maintain aspect ratio.
  const width  = 200;

  // Use the sharp module to resize the image and save in a buffer.
  return await sharp(origImage.Body).resize(width).toBuffer();
}

const publishThumbnailToS3 = async (dstBucket, dstKey, bufferThumbnail) => {
  // Upload the thumbnail image to the destination bucket
  const destParams = {
    Bucket: dstBucket,
    Key: dstKey,
    Body: bufferThumbnail,
    ContentType: "image"
  };

  const putResult = await s3.putObject(destParams).promise();
  console.log(putResult);
}
