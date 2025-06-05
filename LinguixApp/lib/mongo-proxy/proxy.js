const express = require('express');
const axios = require('axios');
const app = express();

app.use(express.json());

// Enable CORS for all routes
app.use((req, res, next) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }
  next();
});

// Proxy route for /api/*
app.all('/api/*', async (req, res) => {
  try {
    const targetUrl = `https://api.x.ai${req.url.replace('/api', '')}`;
    console.log(`Forwarding request: ${req.method} ${targetUrl}`);

    const response = await axios({
      method: req.method,
      url: targetUrl,
      headers: {
        ...req.headers,
        host: 'api.x.ai',
        'Access-Control-Allow-Origin': undefined, // Remove CORS headers from forwarded request
      },
      data: req.body,
    });

    res.status(response.status).json(response.data);
  } catch (error) {
    console.error('Proxy error:', error.message);
    res.status(error.response?.status || 500).json({
      error: error.message,
      details: error.response?.data,
    });
  }
});

// Start server
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Proxy server running on http://localhost:${PORT}`);
});