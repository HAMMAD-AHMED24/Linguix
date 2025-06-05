const express = require('express');
const { MongoClient } = require('mongodb');
const axios = require('axios');
const app = express();
const port = 3000;

const url = 'mongodb://localhost:27017';
const dbName = 'Duolingo';

app.use(express.json());
app.use((req, res, next) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
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
app.all('/api/grok3', async (req, res) => {
  try {
    const targetUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent';
    console.log(`Forwarding request: ${req.method} ${targetUrl}`);
    console.log('Incoming request headers:', JSON.stringify(req.headers, null, 2));
    console.log('Request body:', req.body);

    const authHeader = req.headers['authorization'] || req.headers['Authorization'];
    if (!authHeader) {
      console.error('No Authorization header found in the request');
      return res.status(400).json({ error: 'Missing Authorization header' });
    }
    console.log('Found Authorization header:', authHeader);

    const apiKey = authHeader.replace('Bearer ', '');
    const response = await axios({
      method: 'POST',
      url: `${targetUrl}?key=${apiKey}`,
      headers: {
        'Content-Type': 'application/json',
      },
      data: {
        contents: [
          {
            parts: [
              { text: req.body.messages[0].content },
            ],
          },
        ],
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

// Placeholder routes for other endpoints
app.get('/api/ai-suggestion', (req, res) => {
  res.status(501).json({ error: 'Not implemented' });
});

app.get('/api/daily-words', (req, res) => {
  res.status(501).json({ error: 'Not implemented' });
});

app.get('/api/exercises', (req, res) => {
  res.status(501).json({ error: 'Not implemented' });
});

app.get('/api/dialogues', (req, res) => {
  res.status(501).json({ error: 'Not implemented' });
});

// Existing MongoDB routes remain unchanged
app.post('/api/saveQuizProgress', (req, res) => {
  const { userId, language, score, total, date } = req.body;
  if (!userId || !language || score == null || total == null || !date) {
    return res.status(400).send('Missing required fields');
  }
  db.collection('quiz_progress').insertOne({ userId, language, score, total, date })
    .then(result => res.status(200).send('Progress saved'))
    .catch(err => res.status(500).send('Error saving progress: ' + err));
});

app.get('/api/getQuizProgress/:userId', (req, res) => {
  const userId = req.params.userId;
  if (!userId) {
    return res.status(400).send('Missing userId');
  }
  db.collection('quiz_progress').find({ userId }).toArray()
    .then(result => res.status(200).json(result))
    .catch(err => res.status(500).send('Error fetching progress: ' + err));
});

app.get('/api/getAssignments', (req, res) => {
  db.collection('assignments').find().toArray()
    .then(result => res.status(200).json(result))
    .catch(err => res.status(500).send('Error fetching assignments: ' + err));
});

app.post('/api/insertSampleAssignments', (req, res) => {
  db.collection('assignments').countDocuments()
    .then(count => {
      if (count === 0) {
        return db.collection('assignments').insertMany([
          {
            title: 'Practice Greetings in Arabic',
            description: 'Learn and practice 5 common greetings in Arabic.',
            dueDate: new Date('2025-06-05T00:00:00.000Z'),
          },
          {
            title: 'Urdu Vocabulary Quiz',
            description: 'Complete a quiz on 10 Urdu vocabulary words.',
            dueDate: new Date('2025-06-10T00:00:00.000Z'),
          },
        ]);
      }
      return Promise.resolve();
    })
    .then(() => res.status(200).send('Sample assignments inserted or already exist'))
    .catch(err => res.status(500).send('Error inserting sample assignments: ' + err));
});

app.post('/api/saveAssignment', (req, res) => {
  const { title, description, dueDate } = req.body;
  if (!title || !description || !dueDate) {
    return res.status(400).send('Missing required fields');
  }
  db.collection('assignments').insertOne({ title, description, dueDate })
    .then(result => res.status(200).send('Assignment saved'))
    .catch(err => res.status(500).send('Error saving assignment: ' + err));
});

app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});