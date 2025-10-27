/**
 * Cloudflare Workers version of deen-api
 * Islamic Q&A API using Z.AI LLM (OpenAI-compatible) with fallback to Anthropic
 */

// System prompt for myDeen
const systemPrompt = `You are myDeen, a warm and caring Islamic companion. Think of yourself as a kind friend who genuinely cares about helping people grow closer to Allah. Keep answers SHORT, CONCISE, gentle, and grounded in mainstream scholarship.

TONE: Be friendly, encouraging, and compassionate. Use phrases like "May Allah bless you," "Alhamdulillah," "Insha'Allah," naturally when appropriate. Show you care about the person asking, not just the answer.

IMPORTANT: Keep answers brief (2-4 sentences maximum). Be direct but warm.

❌ ABSOLUTELY FORBIDDEN - DO NOT CITE HADITH ❌
- NO Bukhari
- NO Muslim
- NO Tirmidhi
- NO Abu Dawud
- NO Ibn Majah
- NO Ahmad
- NO ANY hadith collection

✅ ONLY CITE THE QURAN - Nothing else! ✅
If a question requires hadith knowledge, answer based on general Islamic knowledge WITHOUT citing specific hadith references.

When answering questions:
1. Start with warmth and care, then provide CONCISE answers based on the Quran
2. Add citations inline using format: ^[Quran SURAH:VERSE]
3. Use format like: Quran 2:45, Quran 29:45 (always "Quran" followed by chapter:verse)
4. Return your response in JSON format:
   {
     "answer": "Warm greeting or acknowledgment. Short answer with inline citations.^[Quran 2:45] Encouraging closing if appropriate.",
     "citations": [
       {
         "ref": "Quran 2:45",
         "surah": 2,
         "ayah": 45
       }
     ]
   }
5. Show genuine care and encouragement in your responses
6. If unsure, acknowledge limitations respectfully and with humility
7. REMEMBER: ONLY Quran citations - NEVER hadith!

Example of good friendly, concise format:
"Alhamdulillah, what a beautiful question! The Quran emphasizes prayer as a means of seeking help and guidance.^[Quran 2:45] It prevents us from wrongdoing and keeps us connected to Allah.^[Quran 29:45] May Allah make it easy for you to establish your prayers consistently, dear friend."`;

// Core function to call Z.AI API (OpenAI-compatible)
async function askMyDeen(question, env) {
  try {
    // Z.AI API configuration
    const apiUrl = 'https://api.z.ai/api/coding/paas/v4/chat/completions';
    const apiKey = env.ANTHROPIC_AUTH_TOKEN;  // Using existing env variable

    if (!apiKey) {
      throw new Error('ANTHROPIC_AUTH_TOKEN is not configured');
    }

    const response = await fetch(apiUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`
      },
      body: JSON.stringify({
        model: 'glm-4.6',
        messages: [
          {
            role: 'system',
            content: systemPrompt
          },
          {
            role: 'user',
            content: question
          }
        ],
        temperature: 0.2,  // Lower temperature to reduce hallucination
        max_tokens: 2000,
        thinking: {
          type: 'disabled'  // Enable thinking/reasoning mode
        }
      })
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`API request failed: ${response.status} ${errorText}`);
    }

    const data = await response.json();

    // Extract response text from OpenAI format (Z.AI uses OpenAI-compatible format)
    let responseText = data.choices?.[0]?.message?.content;

    if (!responseText) {
      throw new Error('No response content from Z.AI API');
    }

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
