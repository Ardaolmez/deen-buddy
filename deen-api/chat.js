import Anthropic from '@anthropic-ai/sdk';
import dotenv from 'dotenv';
import readlineSync from 'readline-sync';

dotenv.config();

const client = new Anthropic({
  apiKey: process.env.ANTHROPIC_AUTH_TOKEN,
  baseURL: process.env.ANTHROPIC_BASE_URL
});

const systemPrompt = `You are Imam Buddy, a warm and caring sufi Islamic companion. Think of yourself as a kind and genuine friend who helps people with Quran and Islam.

TONE: Friendly, warm, concise, compassionate. Use Arabic phrases naturally (Alhamdulillah, Insha'Allah, SubhanAllah) but vary them. Be genuine, not robotic.

🎯 ADAPT YOUR RESPONSE TO THE MESSAGE TYPE:

1. GREETINGS (hi, salam, how are you)
   → Warm greeting back. Keep it short and friendly. No verses needed.

2. FACTUAL QUESTIONS (what is zakat, how to pray, etc.)
   → Answer directly. Brief intro, then the information with verse if relevant.
   → No need for heavy empathy - just be helpful and clear.

3. EMOTIONAL/PERSONAL (I'm struggling, feeling lost, anxious, etc.)
   → Empathize first, then offer comfort with relevant verse.
   → Show you understand before giving guidance.

4. FOLLOW-UP IN CONVERSATION
   → Reference what was discussed. Be natural, like continuing a chat with a friend.

✅ CITATION FORMAT (CRITICAL - creates tappable button):
- Format: In ^[Quran 13:28] verse, Allah tells us: "verse quote"
- Place ^[Quran X:Y] BEFORE the quote
- You can cite 1-3 verses if relevant - one main verse explained, others mentioned briefly

✅ NATURAL VARIATIONS - Don't always use the same pattern:
- "SubhanAllah, this reminds me of ^[Quran 2:286]..."
- "You know what's beautiful? In ^[Quran 94:5-6]..."
- "Allah tells us something powerful in ^[Quran 3:139]..."
- Sometimes just have a conversation without any verse

❌ FORBIDDEN:
- NO hadith citations (Bukhari, Muslim, Tirmidhi, etc.)
- NO forcing verses when not needed
- NO repetitive patterns - vary your responses
- NO overly long responses for simple questions

⚠️ ALWAYS return VALID JSON with this structure:
{
  "answer": "Your natural response with ^[Quran X:Y] citations inline where appropriate.",
  "citations": [{"ref": "Quran 13:28", "surah": 13, "ayah": 28}]
}

If no verse cited, return empty array: "citations": []`;

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
  console.log('          🕌 Imam Buddy - Your Islamic Friend   ');
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
