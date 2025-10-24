import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import dotenv from 'dotenv';
import { askMyDeen } from './myDeen.js';
import fs from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3000;
const LOGS_DIR = path.join(__dirname, 'logs');

// Ensure logs directory exists
async function ensureLogsDir() {
  try {
    await fs.access(LOGS_DIR);
  } catch {
    await fs.mkdir(LOGS_DIR, { recursive: true });
  }
}

// Log dialogue to file
async function logDialogue(question, response, metadata) {
  const timestamp = new Date().toISOString();
  const logEntry = {
    timestamp,
    question,
    response,
    metadata
  };

  const logFile = path.join(LOGS_DIR, `dialogues-${new Date().toISOString().split('T')[0]}.jsonl`);

  try {
    await fs.appendFile(logFile, JSON.stringify(logEntry) + '\n');
  } catch (error) {
    console.error('Failed to log dialogue:', error);
  }
}

// Middleware
app.use(helmet()); // Security headers
app.use(cors()); // Enable CORS
app.use(express.json({ limit: '10mb' }));

// Rate limiting: 100 requests per 15 minutes per IP
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  message: { error: 'Too many requests, please try again later.' }
});

app.use('/api/', limiter);

// Request logging middleware
app.use((req, res, next) => {
  const timestamp = new Date().toISOString();
  console.log(`[${timestamp}] ${req.method} ${req.path} - IP: ${req.ip}`);
  next();
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// API endpoint for asking questions
app.post('/api/ask', async (req, res) => {
  try {
    const { question } = req.body;

    // Validation
    if (!question || typeof question !== 'string') {
      return res.status(400).json({
        error: 'Invalid request. "question" field is required and must be a string.'
      });
    }

    if (question.trim().length === 0) {
      return res.status(400).json({
        error: 'Question cannot be empty.'
      });
    }

    if (question.length > 1000) {
      return res.status(400).json({
        error: 'Question is too long. Maximum 1000 characters.'
      });
    }

    // Process the question
    const startTime = Date.now();
    const result = await askMyDeen(question);
    const processingTime = Date.now() - startTime;

    // Log the dialogue
    await logDialogue(question, result, {
      ip: req.ip,
      userAgent: req.get('user-agent'),
      processingTime
    });

    // Send response
    res.json({
      success: true,
      data: result,
      metadata: {
        processingTime
      }
    });

  } catch (error) {
    console.error('Error processing request:', error);

    res.status(500).json({
      error: 'An error occurred while processing your question.',
      message: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Endpoint not found',
    availableEndpoints: [
      'GET /health',
      'POST /api/ask'
    ]
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({
    error: 'Internal server error'
  });
});

// Start server
async function startServer() {
  await ensureLogsDir();

  app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 myDeen API Server running on port ${PORT}`);
    console.log(`📝 Health check: http://localhost:${PORT}/health`);
    console.log(`💬 API endpoint: http://localhost:${PORT}/api/ask`);
    console.log(`📂 Logs directory: ${LOGS_DIR}`);
  });
}

startServer().catch(console.error);
