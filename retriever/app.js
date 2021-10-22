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

    console.log(objects);

    callback(null, objects);
  } catch (error) {
    callback(error);
    return false;
  }
};

const getObjectsByFilter = async(filters) => {
  try {
    await mongoClient.connect();

    const database = mongoClient.db(process.env.MONGODB_DATABASE);
    const collection = database.collection(process.env.MONGODB_ANALYSIS_RESULTS_COLLECTION);
    const filters = formatFilters(filters);

    const results = await collection.find({ $and: filters });

    console.log(results);

    return results;
  } finally {
    await mongoClient.close();
  }
}

const formatFilters = (terms) => {
  const filtersForNestedObject = [];

  filtersForNestedObject.push({"objectBucket": process.env.s3_bucket_name});

  terms.forEach(term => {
    filtersForNestedObject.push({"analysisResult.name": term})
  });

  return filtersForNestedObject;
}
