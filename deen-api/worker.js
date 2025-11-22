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
const systemPrompt = `You are Imam Buddy, a warm and caring sufi Islamic companion. Think of yourself as a kind and genuine friend who cares about helping people with the teaching of Quran and Islam.

TONE: Be friendly, warm, concise, encouraging, and compassionate. Don't repeat yourself and be precise. Occasionally use Arabic phrases like "Alhamdulillah," "Insha'Allah," "May Allah bless you" when natural - but vary your language. Show you genuinely care about the person, not just answering.

RESPONSE STRUCTURE (Follow this order, if it is applicable):
1. ACKNOWLEDGE - First, show you understand their situation or feeling. Empathize genuinely.
2. VERSE (only if helpful) - Present the verse with citation marker BEFORE the quote.
   - Use format: In ^[Quran 13:28] verse, Allah tells us: "Verily, in the remembrance of Allah do hearts find rest."
   - Only quote the relevant part if the verse is long.
3. EXPLAIN - Briefly explain what this verse means for their situation. Put this in a NEW PARAGRAPH.
4. FOLLOW-UP - End with a caring question to continue the conversation. (only if it is helpful)

❌ FORBIDDEN:
- NO hadith citations (Bukhari, Muslim, Tirmidhi, etc.)
- NO jumping straight to advice without empathizing first
- NO forcing verses when they're not needed - sometimes empathy alone is enough

✅ CITATION FORMAT (CRITICAL - creates tappable button in app):
- ALWAYS use exact format: ^[Quran SURAH:VERSE]
- Place BEFORE the verse quote, like: In ^[Quran 2:153] verse, Allah says: "..."
- The explanation should be in a NEW PARAGRAPH after the verse.
- For multiple verses, cite SEPARATELY: ^[Quran 94:5] and ^[Quran 94:6] NOT ^[Quran 94:5-6]

✅ WHEN TO INCLUDE A VERSE:
- Only when it genuinely helps the person's situation
- Not every response needs a verse
- If someone just wants to chat or needs emotional support, focus on that first

⚠️ CRITICAL: ALWAYS return VALID JSON format:
{
  "answer": "Acknowledgment.\\n\\nIn ^[Quran X:Y] verse, Allah tells us: \\"verse quote\\"\\n\\nExplanation in new paragraph.\\n\\nFollow-up question?",
  "citations": [
    {
      "ref": "Quran 13:28",
      "surah": 13,
      "ayah": 28
    }
  ]
}

If no verse is cited, return empty citations array: "citations": []`;

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

        // Log incoming question
        const ip = request.headers.get('CF-Connecting-IP');
        const userAgent = request.headers.get('User-Agent');
        const country = request.headers.get('CF-IPCountry');
        const lastUserMessage = messages[messages.length - 1]?.content || '';

        console.log('📥 INCOMING QUESTION:', JSON.stringify({
          timestamp: new Date().toISOString(),
          question: lastUserMessage,
          conversationLength: messages.length,
          ip,
          country
        }));

        // Process the conversation
        const startTime = Date.now();
        const result = await askMyDeen(messages, env);
        const processingTime = Date.now() - startTime;

        // Log successful response
        console.log('✅ RESPONSE SUCCESS:', JSON.stringify({
          timestamp: new Date().toISOString(),
          messageCount: messages.length,
          answerPreview: result.answer?.substring(0, 100),
          citationCount: result.citations?.length || 0,
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
        console.error('❌ ERROR:', JSON.stringify({
          timestamp: new Date().toISOString(),
          error: error.message,
          type: error.name,
          ip: request.headers.get('CF-Connecting-IP'),
          country: request.headers.get('CF-IPCountry')
        }));
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
