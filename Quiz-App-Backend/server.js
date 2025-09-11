const express = require('express');
const { MongoClient, ServerApiVersion, ObjectId } = require('mongodb'); // ObjectId for working with _id
const app = express();
const port = 3000; // You can change this port if 3000 is in use

// Connection URI for your LOCAL MongoDB instance
// If your MongoDB is running locally on the default port, this is usually correct.
// 'quizAppDB' will be the name of your database. It will be created if it doesn't exist.
const uri = "mongodb://localhost:27017/QuizApp"; // Or "mongodb://127.0.0.1:27017/quizAppDB"

// Create a MongoClient with a MongoClientOptions object to set the Stable API version
const client = new MongoClient(uri, {
  serverApi: {
    version: ServerApiVersion.v1,
    strict: true,
    deprecationErrors: true,
  }
});

let db; // Variable to hold the database connection

async function connectToMongo() {
  try {
    await client.connect();
    db = client.db("QuizApp"); // Use your desired database name
    console.log("Pinged your deployment. You successfully connected to local MongoDB!");

    try {
      await db.createCollection("quizzes");
      console.log("Ensured 'quizzes' collection exists.");
      } catch (err) {
        if (err.codeName === 'NamespaceExists') {
           console.log("'quizzes' collection already exists.");
        } else {
            console.error("Error ensuring 'quizzes' collection exists", err);
            }
     }

  } catch (err) {
    console.error("Failed to connect to MongoDB", err);
    process.exit(1); // Exit if DB connection fails
  }
}

connectToMongo(); // Connect to MongoDB when the server starts

app.use(express.json()); // Middleware to parse JSON request bodies

// --- API Endpoints ---

// GET /api/quizzes - Fetch all quizzes
app.get('/api/quizzes', async (req, res) => {
  if (!db) return res.status(503).json({ message: "Database not connected" });
  try {
    const quizzesCollection = db.collection("quizzes");
    const quizzes = await quizzesCollection.find({}).toArray();
    res.json(quizzes);
  } catch (err) {
    console.error("Error fetching quizzes:", err);
    res.status(500).json({ message: "Failed to fetch quizzes" });
  }
});

// POST /api/quizzes - Create a new quiz
app.post('/api/quizzes', async (req, res) => {
  if (!db) return res.status(503).json({ message: "Database not connected" });
  try {
    const quizzesCollection = db.collection("quizzes");
    const newQuizData = req.body; // Expects JSON like: { "title": "Math Quiz", "questions": [] }

    // Basic validation (you'll want more robust validation)
    if (!newQuizData.title) {
      return res.status(400).json({ message: "Quiz title is required" });
    }

    const result = await quizzesCollection.insertOne(newQuizData);
    // Send back the inserted document or just its ID
    const insertedQuiz = await quizzesCollection.findOne({ _id: result.insertedId });
    res.status(201).json(insertedQuiz);

  } catch (err) {
    console.error("Error creating quiz:", err);
    res.status(500).json({ message: "Failed to create quiz" });
  }
});

// GET /api/quizzes/:id - Fetch a single quiz by its ID
app.get('/api/quizzes/:id', async (req, res) => {
  if (!db) return res.status(503).json({ message: "Database not connected" });
  try {
    const quizzesCollection = db.collection("quizzes");
    const quizId = req.params.id;

    if (!ObjectId.isValid(quizId)) {
        return res.status(400).json({ message: "Invalid Quiz ID format" });
    }

    const quiz = await quizzesCollection.findOne({ _id: new ObjectId(quizId) });

    if (quiz) {
      res.json(quiz);
    } else {
      res.status(404).json({ message: "Quiz not found" });
    }
  } catch (err) {
    console.error("Error fetching quiz:", err);
    res.status(500).json({ message: "Failed to fetch quiz" });
  }
});


// --- Start the Server ---
app.listen(port, () => {
  console.log(`Backend server listening at http://localhost:${port}`);
});

// Graceful shutdown
process.on('SIGINT', async () => {
  console.log("Closing MongoDB connection...");
  await client.close();
  process.exit(0);
});
