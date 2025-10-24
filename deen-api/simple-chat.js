import { askMyDeen } from './myDeen.js';
import * as readline from 'node:readline';
import { stdin as input, stdout as output } from 'node:process';

async function askWithLoading(question) {
  console.log('\n💭 Thinking...\n');
  const result = await askMyDeen(question);
  return result;
}

function displayResult(result) {
  if (!result) return;

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

async function main() {
  console.log('═══════════════════════════════════════════════');
  console.log('           🕌 myDeen - Islamic Guide           ');
  console.log('═══════════════════════════════════════════════');
  console.log('Ask any question about Islam. Type "exit" to quit.\n');

  const rl = readline.createInterface({ input, output });

  const askQuestion = () => {
    rl.question('\n❓ Your question: ', async (question) => {
      if (question.toLowerCase() === 'exit' || question.toLowerCase() === 'quit') {
        console.log('\n🌙 As-salamu alaykum! May Allah bless you.\n');
        rl.close();
        return;
      }

      if (!question.trim()) {
        console.log('⚠️  Please enter a question.');
        askQuestion();
        return;
      }

      const result = await askWithLoading(question);
      displayResult(result);

      askQuestion();
    });
  };

  askQuestion();
}

main().catch(console.error);
