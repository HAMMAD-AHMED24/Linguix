const express = require('express');
const { MongoClient, ObjectId } = require('mongodb');
const cors = require('cors');


const axios = require('axios');
const app = express();
const port = 3000;

const url = 'mongodb://localhost:27017';
const dbName = 'Duolingo';

app.use(cors());
app.use(express.json());
app.use((req, res, next) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }
  next();
});

let db;
MongoClient.connect(url, { useNewUrlParser: true, useUnifiedTopology: true })
  .then(client => {
    db = client.db(dbName);
    console.log('Connected to MongoDB');
  })
  .catch(err => console.error('MongoDB connection error:', err));

// Proxy route for AI suggestions (/api/grok3)
app.post('/api/grok3', async (req, res) => {
  try {
    const targetUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
    console.log(`Forwarding request: ${req.method} ${targetUrl}`);
    console.log('Request body:', req.body);

    const authHeader = req.headers['authorization'] || req.headers['Authorization'];
    if (!authHeader) {
      console.error('No Authorization header found in the request');
      return res.status(400).json({ error: 'Missing Authorization header' });
    }
    const apiKey = authHeader.replace('Bearer ', '');

    const response = await axios({
      method: 'POST',
      url: `${targetUrl}?key=${apiKey}`,
      headers: {
        'Content-Type': 'application/json',
      },
      data: {
        contents: req.body.contents,
        generationConfig: {
          temperature: 0.7,
          maxOutputTokens: 100,
        },
      },
      timeout: 10000,
    });

    console.log('Response status:', response.status);
    console.log('Response data:', response.data);
    res.status(response.status).json({
      choices: [
        {
          message: {
            role: 'assistant',
            content: response.data.candidates[0].content.parts[0].text,
          },
        },
      ],
    });
  } catch (error) {
    console.error('Proxy error:', error.message);
    console.error('Error response:', error.response?.status, error.response?.data);
    res.status(error.response?.status || 500).json({
      error: error.message,
      details: error.response?.data || 'No additional details',
    });
  }
});

// Endpoint to save quiz progress
app.post('/api/progress', async (req, res) => {
  console.log('Received POST /api/progress:', req.body);
  try {
    if (!db) throw new Error('Database not connected');
    const { userId, language, quizData } = req.body;
    if (!userId || !language || !quizData) {
      return res.status(400).json({ error: 'Missing required fields: userId, language, quizData' });
    }

    const progress = {
      userId,
      language,
      quizData,
      timestamp: new Date(),
    };

    const result = await db.collection('progress').insertOne(progress);
    console.log('Progress saved:', result.insertedId);
    res.status(201).json({ message: 'Progress saved', id: result.insertedId });
  } catch (error) {
    console.error('Error saving progress:', error.message);
    res.status(500).json({ error: 'Failed to save progress', details: error.message });
  }
});

// Endpoint to get progress
app.get('/api/progress/:userId/:language', async (req, res) => {
  console.log(`Received GET /api/progress/${req.params.userId}/${req.params.language}`);
  try {
    if (!db) throw new Error('Database not connected');
    const { userId, language } = req.params;
    if (!userId || !language) {
      return res.status(400).json({ error: 'Missing userId or language' });
    }

    const progress = await db.collection('progress')
      .find({ userId, language })
      .sort({ timestamp: -1 })
      .toArray();
    if (!progress.length) {
      return res.status(404).json({ message: 'No progress found' });
    }
    console.log('Progress retrieved:', progress);
    res.status(200).json(progress);
  } catch (error) {
    console.error('Error retrieving progress:', error.message);
    res.status(500).json({ error: 'Failed to retrieve progress', details: error.message });
  }
});

app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});