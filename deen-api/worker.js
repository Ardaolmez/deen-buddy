/**
 * Cloudflare Workers version of deen-api
 * Islamic Q&A API using Z.AI LLM (OpenAI-compatible) with fallback to Anthropic
 *
 * OBSERVABILITY:
 * - Logs: All console.log/error outputs are captured in Cloudflare dashboard
 * - Analytics Engine: Tracks custom metrics:
 *   - Blobs: [endpoint, method, country, status]
 *   - Doubles: [processingTime_ms, messageCount, citationCount]
 *   - Indexes: [IP address]
 *
 * View logs at: https://dash.cloudflare.com → Workers → deen-api → Logs
 * Query analytics: https://dash.cloudflare.com → Analytics & Logs → Workers Analytics
 */

// System prompt for Imam Buddy
const systemPrompt = `You are Imam Buddy, a warm and caring Islamic companion. Think of yourself as a kind friend who genuinely cares about helping people grow closer to Allah. Keep answers SHORT, CONCISE, gentle, and grounded in mainstream scholarship.

TONE: Be friendly, encouraging, and compassionate. Occasionally use Arabic phrases like "May Allah bless you," "Alhamdulillah," "Insha'Allah," when it feels natural - but don't use them in every response. Keep variety in your language and avoid being repetitive. Show you care about the person asking, not just the answer.

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
2. Add citations inline using EXACT format: ^[Quran SURAH:VERSE]
3. Citation format rules:
   ✅ CORRECT: Quran 2:45 (space after "Quran", single verse)
   ✅ CORRECT: Quran 29:45 (always "Quran" + space + chapter + colon + verse)
   ❌ WRONG: Quran:2:45 (no colon after Quran)
   ❌ WRONG: Quran 1:6-7 (no ranges - cite each verse separately)
   ❌ WRONG: Quran 2:45-46 (cite as: Quran 2:45 and Quran 2:46)
4. If multiple verses, cite each one separately with its own citation
5. ⚠️ CRITICAL: ALWAYS return VALID JSON format - NEVER plain text:
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
8. ALWAYS respond with VALID JSON - the response MUST be parseable by JSON.parse()

Example of CORRECT JSON response:
{
  "answer": "Alhamdulillah, what a beautiful question! The Quran emphasizes prayer as a means of seeking help and guidance.^[Quran 2:45] It prevents us from wrongdoing and keeps us connected to Allah.^[Quran 29:45] May Allah make it easy for you to establish your prayers consistently, dear friend.",
  "citations": [
    {"ref": "Quran 2:45", "surah": 2, "ayah": 45},
    {"ref": "Quran 29:45", "surah": 29, "ayah": 45}
  ]
}`;

// Estimate tokens (rough approximation: ~4 chars per token)
function estimateTokens(text) {
  return Math.ceil(text.length / 4);
}

// Trim messages to fit within token budget (~8k tokens for safety)
function trimMessagesToFitBudget(messages, maxTokens = 8000) {
  // System prompt tokens
  const systemTokens = estimateTokens(systemPrompt);
  let availableTokens = maxTokens - systemTokens;

  // Count from most recent messages backwards
  const trimmedMessages = [];
  for (let i = messages.length - 1; i >= 0; i--) {
    const msgTokens = estimateTokens(messages[i].content);
    if (availableTokens - msgTokens < 0) {
      break; // Skip older messages that don't fit
    }
    trimmedMessages.unshift(messages[i]);
    availableTokens -= msgTokens;
  }

  return trimmedMessages;
}

// Core function to call Z.AI API (OpenAI-compatible)
async function askMyDeen(messages, env) {
  try {
    // Z.AI API configuration
    const apiUrl = 'https://api.z.ai/api/coding/paas/v4/chat/completions';
    const apiKey = env.ANTHROPIC_AUTH_TOKEN;  // Using existing env variable

    if (!apiKey) {
      throw new Error('ANTHROPIC_AUTH_TOKEN is not configured');
    }

    // Trim messages to fit budget
    const trimmedMessages = trimMessagesToFitBudget(messages);

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
          ...trimmedMessages
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

    // Try to parse as JSON
    let jsonResponse;
    try {
      jsonResponse = JSON.parse(responseText);
    } catch (parseError) {
      // Fallback: If response is plain text instead of JSON, wrap it
      console.warn('LLM returned plain text instead of JSON, wrapping it');
      console.log('Raw text:', responseText.substring(0, 200));

      // Extract any Quran citations from plain text
      const citationRegex = /\^?\[Quran (\d+):(\d+)\]/g;
      const citations = [];
      let match;
      while ((match = citationRegex.exec(responseText)) !== null) {
        citations.push({
          ref: `Quran ${match[1]}:${match[2]}`,
          surah: parseInt(match[1]),
          ayah: parseInt(match[2])
        });
      }

      jsonResponse = {
        answer: responseText.trim(),
        citations: citations
      };
    }

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
        let messages;

        // Backward compatibility: support both old and new formats
        if (body.question && typeof body.question === 'string') {
          // Old format: {"question": "..."}
          messages = [{ role: 'user', content: body.question }];
        } else if (body.messages && Array.isArray(body.messages)) {
          // New format: {"messages": [...]}
          messages = body.messages;
        } else {
          return jsonResponse({
            error: 'Invalid request. Either "question" (string) or "messages" (array) field is required.'
          }, 400);
        }

        // Validation
        if (messages.length === 0) {
          return jsonResponse({
            error: 'Messages array cannot be empty.'
          }, 400);
        }

        // Validate message format
        for (const msg of messages) {
          if (!msg.role || !msg.content) {
            return jsonResponse({
              error: 'Each message must have "role" and "content" fields.'
            }, 400);
          }
          if (!['user', 'assistant'].includes(msg.role)) {
            return jsonResponse({
              error: 'Message role must be "user" or "assistant".'
            }, 400);
          }
        }

        // Process the conversation
        const startTime = Date.now();
        const result = await askMyDeen(messages, env);
        const processingTime = Date.now() - startTime;

        // Log to console for Cloudflare dashboard
        const ip = request.headers.get('CF-Connecting-IP');
        const userAgent = request.headers.get('User-Agent');
        const country = request.headers.get('CF-IPCountry');
        console.log(JSON.stringify({
          timestamp: new Date().toISOString(),
          messageCount: messages.length,
          lastMessage: messages[messages.length - 1]?.content?.substring(0, 100),
          ip,
          country,
          userAgent,
          processingTime,
          status: 'success'
        }));

        // Track analytics if available
        if (env.ANALYTICS) {
          env.ANALYTICS.writeDataPoint({
            blobs: [
              path,                          // endpoint
              request.method,                // HTTP method
              country || 'unknown',          // country code
              'success'                      // status
            ],
            doubles: [
              processingTime,                // response time in ms
              messages.length,               // conversation length
              result.citations?.length || 0  // citation count
            ],
            indexes: [ip]                    // IP address for filtering
          });
        }

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
        console.error('Error stack:', error.stack);

        // Track error in analytics
        if (env.ANALYTICS) {
          const ip = request.headers.get('CF-Connecting-IP');
          const country = request.headers.get('CF-IPCountry');
          env.ANALYTICS.writeDataPoint({
            blobs: [
              path,
              request.method,
              country || 'unknown',
              'error'                        // status
            ],
            doubles: [0, 0, 0],              // no timing/count data for errors
            indexes: [ip || 'unknown']
          });
        }

        return jsonResponse({
          error: 'An error occurred while processing your question.',
          message: error.message,  // Always include error message for debugging
          stack: env.NODE_ENV === 'development' ? error.stack : undefined
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
