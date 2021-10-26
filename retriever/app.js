// dependencies
const { MongoClient } = require("mongodb");
const Redis = require("ioredis");
const util = require('util');

// mongoDB setup
const uri = `mongodb://${process.env.MONGODB_USER}:${process.env.MONGODB_PASSWORD}@${process.env.MONGODB_HOST}/${process.env.MONGODB_DATABASE}?retryWrites=true&w=majority`;
const mongoClient = new MongoClient(uri);

// Redis setup
const redis = new Redis({
  host: process.env.REDIS_ADDRESS, // Redis host
  port: process.env.REDIS_PORT, // Redis port
  username: process.env.REDIS_USER,
  password: process.env.REDIS_PASSWORD,
  maxRetriesPerRequest: 1,
});

exports.handler = async (event, context, callback) => {
  try {
    context.callbackWaitsForEmptyEventLoop = false;
    // Read options from the event parameter.
    console.log("Reading options from event:\n", util.inspect(event, {depth: 5}));
    const body = JSON.parse(event.body);

    const objects = await findObjectsByFilter(body.terms);
    const response = formatAPIGatewayResponse(objects);

    console.log(response);

    callback(null, response);
  } catch (error) {
    callback(error);
    return false;
  }
};

const findObjectsByFilter = async(terms) => {
  try {
    const objectsFromCache = redis ? await findObjectsFromRedisByFilter(terms) : null;

    console.log(`Result from cache: ${objectsFromCache}`);

    return (objectsFromCache && objectsFromCache.length) ? objectsFromCache : await findObjectsFromMongoByFilter(terms);
  } catch (e) {
    console.error(e);
    console.log(`Going to fallback to database...`);

    return await findObjectsFromMongoByFilter(terms);
  }
}

const findObjectsFromMongoByFilter = async(terms) => {
  console.log(`Searching on database...`);
  try {
    await mongoClient.connect();

    const database = mongoClient.db(process.env.MONGODB_DATABASE);
    const collection = database.collection(process.env.MONGODB_ANALYSIS_RESULTS_COLLECTION);
    const filters = formatFiltersForMongoQuery(terms);

    const results = await collection.find({ $and: filters }).toArray();
    console.log(results);

    if (redis) {
      console.log(`Building cache with results...`);
      await redis.set(buildRedisKey(terms), JSON.stringify(results));
    }

    return results;
  } finally {
    await mongoClient.close();
  }
}

const formatFiltersForMongoQuery = (terms) => {
  const filtersForNestedObject = [];

  filtersForNestedObject.push({"imageBucket": process.env.S3_BUCKET_NAME});

  terms.forEach(term => {
    filtersForNestedObject.push({"analysisResult.name": term.toLowerCase()})
  });

  return filtersForNestedObject;
}

const findObjectsFromRedisByFilter = async(terms) => {
  return JSON.parse(await redis.get(buildRedisKey(terms)));
}

const buildRedisKey = (terms) => {
  return `${process.env.ENVIRONMENT}:${terms.join("-")}`;
}

const formatAPIGatewayResponse = (objects) => {
  return {
    isBase64Encoded: false,
    statusCode: 200,
    body: JSON.stringify(objects)
  }
}
