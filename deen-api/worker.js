/**
 * Cloudflare Workers version of deen-api
 * Islamic Q&A API using Anthropic-compatible LLM
 */

// System prompt for myDeen
const systemPrompt = `You are myDeen, a warm and caring Islamic companion. Think of yourself as a kind friend who genuinely cares about helping people grow closer to Allah. Keep answers SHORT, CONCISE, gentle, and grounded in mainstream scholarship.

TONE: Be friendly, encouraging, and compassionate. Use phrases like "May Allah bless you," "Alhamdulillah," "Insha'Allah," naturally when appropriate. Show you care about the person asking, not just the answer.

IMPORTANT: Keep answers brief (2-4 sentences maximum). Be direct but warm.

When answering questions:
1. Start with warmth and care, then provide CONCISE answers based on Quran and authentic Hadith
2. Add citations inline using format: ^[Source Reference]
3. Use refs like: Quran 2:45, Bukhari 527, Muslim 1:234, etc.
4. Return your response in JSON format:
   {
     "answer": "Warm greeting or acknowledgment. Short answer with inline citations.^[Quran 2:45] Encouraging closing if appropriate.",
     "citations": [
       {
         "ref": "Quran 2:45",
         "surah": "Al-Baqarah",
         "ayah": 45,
         "text": "full verse text"
       }
     ]
   }
5. Show genuine care and encouragement in your responses
6. If unsure, acknowledge limitations respectfully and with humility

Example of good friendly, concise format:
"Alhamdulillah, what a beautiful question! The Quran emphasizes prayer as a means of seeking help and guidance.^[Quran 2:45] It prevents us from wrongdoing and keeps us connected to Allah.^[Quran 29:45] May Allah make it easy for you to establish your prayers consistently, dear friend."`;

// Core function to call Anthropic API
async function askMyDeen(question, env) {
  try {
    const response = await fetch(`${env.ANTHROPIC_BASE_URL}/v1/messages`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'anthropic-version': '2023-06-01',
        'x-api-key': env.ANTHROPIC_AUTH_TOKEN
      },
      body: JSON.stringify({
        model: 'glm-4.6',
        max_tokens: 2000,
        system: systemPrompt,
        messages: [
          {
            role: 'user',
            content: question
          }
        ]
      })
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`API request failed: ${response.status} ${errorText}`);
    }

    const data = await response.json();
    let responseText = data.content[0].text;

    // Remove markdown code blocks if present
    const jsonMatch = responseText.match(/```(?:json)?\s*([\s\S]*?)\s*```/);
    if (jsonMatch) {
      responseText = jsonMatch[1];
    }

    // Parse JSON response
    const jsonResponse = JSON.parse(responseText);
    return jsonResponse;
  } catch (error) {
    console.error('Error calling myDeen:', error);
    throw error;
  }
}

// CORS headers
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
  'Access-Control-Max-Age': '86400',
};

// Rate limiting using Cloudflare's built-in KV (optional - can use Workers Rate Limiting API)
// For now, we'll skip rate limiting and rely on Cloudflare's DDoS protection

// JSON response helper
function jsonResponse(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      'Content-Type': 'application/json',
      ...corsHeaders
    }
  });
}

// Main request handler
export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    const path = url.pathname;

    // Handle CORS preflight
    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders });
    }

    // Log request
    console.log(`${request.method} ${path} - IP: ${request.headers.get('CF-Connecting-IP')}`);

    // Health check endpoint
    if (path === '/health' && request.method === 'GET') {
      return jsonResponse({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        worker: 'cloudflare'
      });
    }

    // API endpoint for asking questions
    if (path === '/api/ask' && request.method === 'POST') {
      try {
        const body = await request.json();
        const { question } = body;

        // Validation
        if (!question || typeof question !== 'string') {
          return jsonResponse({
            error: 'Invalid request. "question" field is required and must be a string.'
          }, 400);
        }

        if (question.trim().length === 0) {
          return jsonResponse({
            error: 'Question cannot be empty.'
          }, 400);
        }

        if (question.length > 1000) {
          return jsonResponse({
            error: 'Question is too long. Maximum 1000 characters.'
          }, 400);
        }

        // Process the question
        const startTime = Date.now();
        const result = await askMyDeen(question, env);
        const processingTime = Date.now() - startTime;

        // Optional: Log to Cloudflare Analytics or KV
        // For now, we'll just log to console
        const ip = request.headers.get('CF-Connecting-IP');
        const userAgent = request.headers.get('User-Agent');
        console.log(JSON.stringify({
          timestamp: new Date().toISOString(),
          question,
          ip,
          userAgent,
          processingTime
        }));

        // Send response
        return jsonResponse({
          success: true,
          data: result,
          metadata: {
            processingTime
          }
        });

      } catch (error) {
        console.error('Error processing request:', error);

        return jsonResponse({
          error: 'An error occurred while processing your question.',
          message: env.NODE_ENV === 'development' ? error.message : undefined
        }, 500);
      }
    }

    // 404 handler
    return jsonResponse({
      error: 'Endpoint not found',
      availableEndpoints: [
        'GET /health',
        'POST /api/ask'
      ]
    }, 404);
  }
};
