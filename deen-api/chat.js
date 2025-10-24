import Anthropic from '@anthropic-ai/sdk';
import dotenv from 'dotenv';
import readlineSync from 'readline-sync';

dotenv.config();

const client = new Anthropic({
  apiKey: process.env.ANTHROPIC_AUTH_TOKEN,
  baseURL: process.env.ANTHROPIC_BASE_URL
});

const systemPrompt = `You are myDeen, a kind Islamic guide. Keep answers concise, gentle, and grounded in mainstream scholarship.

When answering questions:
1. Provide clear, respectful answers based on Quran and authentic Hadith
2. Add citations inline using format: ^[Source Reference]
3. Use refs like: Quran 2:45, Bukhari 527, Muslim 1:234, etc.
4. Return your response in JSON format:
   {
     "answer": "your answer text with ^[citations]",
     "citations": [
       {
         "ref": "Quran 2:45",
         "surah": "Al-Baqarah",
         "ayah": 45,
         "text": "full verse text"
       }
     ]
   }
5. Keep tone warm and educational
6. If unsure, acknowledge limitations respectfully`;

async function askMyDeen(question) {
  try {
    console.log('\n💭 Thinking...\n');

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
    console.error('❌ Error:', error.message);
    return null;
  }
}

async function main() {
  console.log('═══════════════════════════════════════════════');
  console.log('           🕌 myDeen - Islamic Guide           ');
  console.log('═══════════════════════════════════════════════');
  console.log('Ask any question about Islam. Type "exit" to quit.\n');

  while (true) {
    const question = readlineSync.question('\n❓ Your question: ');

    if (question.toLowerCase() === 'exit' || question.toLowerCase() === 'quit') {
      console.log('\n🌙 As-salamu alaykum! May Allah bless you.\n');
      break;
    }

    if (!question.trim()) {
      console.log('⚠️  Please enter a question.');
      continue;
    }

    const result = await askMyDeen(question);

    if (result) {
      console.log('\n📖 Answer:');
      console.log('─'.repeat(50));
      console.log(result.answer);

      if (result.citations && result.citations.length > 0) {
        console.log('\n📚 References:');
        console.log('─'.repeat(50));
        result.citations.forEach((citation, index) => {
          console.log(`\n${index + 1}. ${citation.ref}`);
          if (citation.surah) {
            console.log(`   Surah: ${citation.surah}`);
          }
          if (citation.text) {
            console.log(`   "${citation.text}"`);
          }
        });
      }
      console.log('\n' + '─'.repeat(50));
    }
  }
}

main().catch(console.error);
