// Google AI API로 이미지 생성 테스트
const https = require('https');
const fs = require('fs');
const path = require('path');

// .env 파일 직접 읽기
const envPath = path.join(__dirname, '.env');
let API_KEY = process.env.GOOGLE_GENERATIVE_AI_API_KEY;

if (!API_KEY && fs.existsSync(envPath)) {
  const envContent = fs.readFileSync(envPath, 'utf-8');
  const match = envContent.match(/GOOGLE_GENERATIVE_AI_API_KEY=(.+)/);
  if (match) {
    API_KEY = match[1].trim();
  }
}

async function testGoogleImageGeneration() {
  console.log('🧪 Google AI API 이미지 생성 테스트...\n');

  if (!API_KEY) {
    console.error('❌ GOOGLE_GENERATIVE_AI_API_KEY가 없습니다!');
    process.exit(1);
  }

  const prompt = '부산시민공원 봄꽃 축제, 밝고 화사한 분위기, 일러스트레이션 스타일';

  // Method 1: Gemini 2.0 Flash로 시도
  console.log('📝 프롬프트:', prompt);
  console.log('\n1️⃣ Gemini 2.0 Flash로 시도...');

  const requestBody = JSON.stringify({
    contents: [{
      parts: [{
        text: `Generate an image: ${prompt}\n\nImage specifications: 1920x1080, 16:9 aspect ratio, high quality, illustration style`
      }]
    }],
    generationConfig: {
      temperature: 0.9,
      topP: 0.95,
      maxOutputTokens: 8192
    }
  });

  const options = {
    hostname: 'generativelanguage.googleapis.com',
    path: `/v1beta/models/gemini-2.0-flash-exp:generateContent?key=${API_KEY}`,
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(requestBody)
    }
  };

  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        if (res.statusCode === 200) {
          const result = JSON.parse(data);

          // 응답 구조 확인
          console.log('\n✅ API 응답 성공!');
          console.log('응답 구조:', JSON.stringify(result, null, 2).substring(0, 500));

          // 이미지 데이터가 있는지 확인
          const parts = result.candidates?.[0]?.content?.parts;
          if (parts) {
            const hasImage = parts.some(part => part.inline_data || part.image);
            if (hasImage) {
              console.log('\n🎉 이미지 생성 성공! Gemini가 이미지를 생성할 수 있습니다!');
              resolve(true);
            } else {
              console.log('\n❌ Gemini는 이미지 생성을 지원하지 않습니다.');
              console.log('💡 대안: OpenAI DALL-E 3 API 사용 필요');
              resolve(false);
            }
          } else {
            console.log('\n❌ 예상과 다른 응답 구조');
            resolve(false);
          }
        } else {
          console.error(`\n❌ API 오류: ${res.statusCode}`);
          console.error(data);
          reject(new Error(data));
        }
      });
    });

    req.on('error', (error) => {
      console.error('\n❌ 요청 실패:', error.message);
      reject(error);
    });

    req.write(requestBody);
    req.end();
  });
}

testGoogleImageGeneration()
  .then((canGenerate) => {
    if (canGenerate) {
      console.log('\n✅ Google API로 이미지 생성 가능!');
      console.log('👉 generate_images.js를 Google API 버전으로 실행하세요.');
    } else {
      console.log('\n⚠️  Google API로는 이미지 생성 불가');
      console.log('👉 OpenAI DALL-E 3 API 키를 .env에 추가하고 generate_images.js 실행하세요.');
      console.log('\n📌 OpenAI API 키 발급: https://platform.openai.com/api-keys');
    }
  })
  .catch((error) => {
    console.error('\n❌ 테스트 실패:', error.message);
    process.exit(1);
  });
