import dotenv from 'dotenv';

dotenv.config();

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

export async function askMyDeen(question) {
  try {
    // Z.AI API configuration - using existing env variable
    const apiUrl = 'https://api.z.ai/api/coding/paas/v4/chat/completions';
    const apiKey = process.env.ANTHROPIC_AUTH_TOKEN;  // Using existing env variable

    if (!apiKey) {
      throw new Error('ANTHROPIC_AUTH_TOKEN is not configured. Please set it in your .env file.');
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
          type: 'enabled'  // Enable thinking/reasoning mode
        }
      })
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`Z.AI API request failed: ${response.status} ${errorText}`);
    }

    const data = await response.json();

    // Extract text from OpenAI format
    let responseText = data.choices?.[0]?.message?.content;

    // Log reasoning content if available (for debugging)
    if (data.choices?.[0]?.message?.reasoning_content) {
      console.log('AI is thinking...');
    }

    // Process response text
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

// Usage example - only runs when this file is executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
  async function main() {
    console.log('myDeen - Your Islamic Guide\n');
    console.log('Question: Why is prayer important in Islam?\n');

    const result = await askMyDeen("Why is prayer important in Islam?");

    console.log('Answer:');
    console.log(result.answer);
    console.log('\nCitations:');
    console.log(JSON.stringify(result.citations, null, 2));
  }

  main().catch(console.error);
}