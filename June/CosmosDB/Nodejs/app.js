import pkg from 'mongodb';
import dotenv from 'dotenv';

dotenv.config(); // Load environment variables from the .env file

const { MongoClient } = pkg;

// Use process.env.MONGODB_URL to get the MongoDB URI
const uri = process.env.MONGODB_URL; // MongoDB connection string from environment variables

if (!uri) {
  throw new Error("MONGODB_URL is not defined in the environment variables.");
}

console.log("MongoDB URL:", uri);

// Database name
const dbName = "cosmicworks"; // Replace with your database name

// Create a new MongoClient
const client = new MongoClient(uri, { tlsAllowInvalidCertificates: true }); // Add this option to allow invalid certificates

async function run() {
  try {
    // Connect to the MongoDB server
    await client.connect();
    console.log("Connected to MongoDB");

    // Access the database
    const database = client.db(dbName);

    // Access the collection
    const collection = database.collection('products'); // Replace with your collection name

    // Item to insert
    const item = {
      name: 'Kiama classic surfboard'
    };

    // Insert item into the collection
    const result = await collection.insertOne(item);
    console.log('Item inserted:', result);

  } catch (error) {
    console.error('Error connecting to MongoDB:', error);
  } finally {
    if (client && client.close) {
      await client.close();
    }
  }
}

// Run the function
run();
