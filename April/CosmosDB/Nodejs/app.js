import pkg from 'mongodb';
import dotenv from 'dotenv';  // Import dotenv to use environment variables

dotenv.config();  // Load environment variables from the .env file

const { MongoClient } = pkg;

// Use process.env.MONGODB_URL to get the MongoDB URI
const uri = process.env.MONGODB_URL;  // MongoDB connection string from environment variables

// Database name
const dbName = "cosmicworks";  // Replace with your database name

// Create a new MongoClient
const client = new MongoClient(uri, { tlsAllowInvalidCertificates: true });  // Add this option to allow invalid certificates

async function run() {
  try {
    // Connect to the MongoDB server
    await client.connect();
    console.log("Connected to MongoDB");

    // Access the database
    const database = client.db(dbName);

    // Access the collection
    const collection = database.collection('products');  // Replace with your collection name

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
    // Close the connection when done
    await client.close();
  }
}

// Run the function
run();





// import { MongoClient } from 'mongodb';

// // MongoDB connection URI with options
// const uri = "your_mongodb_uri_here?ssl=true";  // Replace with your MongoDB URI

// // Database name
// const dbName = "cosmicworks";  // Replace with your database name

// // Create a new MongoClient
// const client = new MongoClient(uri);

// async function run() {
//   try {
//     // Connect to the MongoDB server
//     await client.connect();

//     // Access the database
//     const database = client.db(dbName);

//     // Access the collection
//     const collection = database.collection('products');  // Replace with your collection name

//     // Item to insert
//     const item = {
//       name: 'Kiama classic surfboard'
//     };

//     // Insert item into the collection
//     const result = await collection.insertOne(item);
//     console.log('Item inserted:', result);

//   } catch (error) {
//     console.error('Error connecting to MongoDB:', error);
//   } finally {
//     // Close the connection when done
//     await client.close();
//   }
// }

// // Run the function
// run();
