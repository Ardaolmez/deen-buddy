import Anthropic from '@anthropic-ai/sdk';
import dotenv from 'dotenv';

dotenv.config();

const client = new Anthropic({
  apiKey: process.env.ANTHROPIC_AUTH_TOKEN,
  baseURL: process.env.ANTHROPIC_BASE_URL
});

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

export async function askMyDeen(question) {
  try {
    const response = await client.messages.create({
      model: 'glm-4.6',
      max_tokens: 2000,
      system: systemPrompt,
      messages: [
        {
          role: 'user',
          content: question
        }
      ]
    });

    // Extract text and handle markdown code blocks
    let responseText = response.content[0].text;

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
