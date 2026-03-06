// Imagen 3 모델 테스트 (generateContent 형식)
const https = require('https');
const fs = require('fs');
const path = require('path');

const envPath = path.join(__dirname, '.env');
let API_KEY = process.env.GOOGLE_GENERATIVE_AI_API_KEY;

if (!API_KEY && fs.existsSync(envPath)) {
  const envContent = fs.readFileSync(envPath, 'utf-8');
  const match = envContent.match(/GOOGLE_GENERATIVE_AI_API_KEY=(.+)/);
  if (match) {
    API_KEY = match[1].trim();
  }
}

const OUTPUT_DIR = path.join(__dirname, 'public', 'proposal_images');

async function testImagen3Gemini() {
  console.log('\n🧪 imagen-3.0-generate-001 테스트 (Gemini 형식)...\n');

  const testPrompt = 'A beautiful spring flower festival in a city park with colorful tulips and cherry blossoms, families enjoying the sunny day, photorealistic style, 16:9 aspect ratio';

  return new Promise((resolve, reject) => {
    // Gemini와 같은 형식 사용
    const requestBody = JSON.stringify({
      contents: [{
        parts: [{
          text: testPrompt
        }]
      }],
      generationConfig: {
        temperature: 0.9,
        topP: 0.95
      }
    });

    const options = {
      hostname: 'generativelanguage.googleapis.com',
      path: `/v1beta/models/imagen-3.0-generate-001:generateContent?key=${API_KEY}`,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(requestBody)
      }
    };

    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => { data += chunk; });
      res.on('end', () => {
        console.log(`📊 HTTP 응답: ${res.statusCode}\n`);

        if (res.statusCode === 200) {
          const result = JSON.parse(data);
          console.log('✅ API 응답 성공!');
          console.log('응답 구조:', JSON.stringify(result, null, 2).substring(0, 800) + '...\n');

          // 이미지 데이터 추출
          const parts = result.candidates?.[0]?.content?.parts;
          if (parts) {
            for (const part of parts) {
              if (part.inlineData && part.inlineData.data) {
                const filepath = path.join(OUTPUT_DIR, 'test_imagen3.png');
                const buffer = Buffer.from(part.inlineData.data, 'base64');
                fs.writeFileSync(filepath, buffer);
                console.log('🎉 Imagen 3 이미지 생성 성공!');
                console.log(`📁 저장: ${filepath}`);
                console.log(`📏 크기: ${(buffer.length / 1024).toFixed(2)} KB\n`);
                resolve(true);
                return;
              }
            }
          }
          console.log('⚠️  이미지 데이터를 찾을 수 없습니다');
          resolve(false);
        } else {
          const error = JSON.parse(data);
          console.log(`❌ API 오류 (${res.statusCode})`);
          console.log(JSON.stringify(error, null, 2));
          resolve(false);
        }
      });
    });

    req.on('error', reject);
    req.write(requestBody);
    req.end();
  });
}

testImagen3Gemini()
  .then(success => {
    if (success) {
      console.log('\n✅ Imagen 3를 사용할 수 있습니다!');
      console.log('💡 10개 이미지를 Imagen 3로 재생성할 수 있습니다.\n');
    } else {
      console.log('\n⚠️  Imagen 3를 사용할 수 없습니다.');
      console.log('대안: gemini-2.5-flash-image 유지 또는 DALL-E 3 시도\n');
    }
  })
  .catch(err => console.error('오류:', err));
