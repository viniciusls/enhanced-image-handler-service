// dependencies
const AWS = require('aws-sdk');
const { MongoClient } = require("mongodb");
const util = require('util');

// mongoDB setup
const uri = `mongodb+srv://${process.env.MONGODB_USER}:${process.env.MONGODB_PASSWORD}@${process.env.MONGODB_HOST}/${process.env.MONGODB_DATABASE}?retryWrites=true&w=majority`;
const mongoClient = new MongoClient(uri);

exports.handler = async (event, context, callback) => {
  try {
    // Read options from the event parameter.
    console.log("Reading options from event:\n", util.inspect(event, {depth: 5}));
    const body = JSON.parse(event.body);

    const objects = await getObjectsByFilter(body.terms);
    const response = formatAPIGatewayResponse(objects);

    console.log(response);

    callback(null, response);
  } catch (error) {
    callback(error);
    return false;
  }
};

const getObjectsByFilter = async(terms) => {
  try {
    await mongoClient.connect();

    const database = mongoClient.db(process.env.MONGODB_DATABASE);
    const collection = database.collection(process.env.MONGODB_ANALYSIS_RESULTS_COLLECTION);
    const filters = formatFilters(terms);

    console.log(filters);

    const results = await collection.find({ $and: filters }).toArray();

    console.log(results);

    return results;
  } finally {
    await mongoClient.close();
  }
}

const formatFilters = (terms) => {
  const filtersForNestedObject = [];

  filtersForNestedObject.push({"objectBucket": process.env.S3_BUCKET_NAME});

  terms.forEach(term => {
    filtersForNestedObject.push({"analysisResult.name": term.toLowerCase()})
  });

  return filtersForNestedObject;
}

const formatAPIGatewayResponse = (objects) => {
  return {
    isBase64Encoded: false,
    statusCode: 200,
    body: JSON.stringify(objects)
  }
}
