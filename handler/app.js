const AWS = require('aws-sdk');
const util = require('util');

const sns = new AWS.SNS({apiVersion: '2010-03-31'});

exports.handler = async (event, context, callback) => {
  try {
    // Read options from the event parameter.
    console.log("Reading options from event:\n", util.inspect(event, {depth: 5}));
    const srcBucket = event.Records[0].s3.bucket.name;

    // Object key may have spaces or unicode non-ASCII characters.
    const srcKey = decodeURIComponent(event.Records[0].s3.object.key.replace(/\+/g, " "));

    await publishToSNSTopic(srcBucket, srcKey);

    console.log(`Successfully published ${srcBucket}/${srcKey} info to ${process.env.SNS_IMAGES_TOPIC_ARN}`);
  } catch (error) {
    console.log(error);
    return false;
  }
};

const publishToSNSTopic = async (bucketName, objectKey) => {
  const messageBody = JSON.stringify({
    BucketName: bucketName,
    ObjectKey: objectKey,
    ObjectName: objectKey.split('/').pop(),
    ObjectExtension: objectKey.split('.').pop()
  });

  const snsPublishParams = {
    Message: {
      default: messageBody,
      sqs: messageBody
    },
    MessageStructure: 'json',
    TopicArn: process.env.SNS_IMAGES_TOPIC_ARN
  };

  const publishResult = await sns.publish(snsPublishParams).promise();
  console.log(publishResult);
}
