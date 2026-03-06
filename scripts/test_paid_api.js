// 유료 API 키 테스트 - 1개 이미지만 생성
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

const OUTPUT_DIR = path.join(__dirname, 'public', 'proposal_images');
if (!fs.existsSync(OUTPUT_DIR)) {
  fs.mkdirSync(OUTPUT_DIR, { recursive: true });
}

async function testPaidAPI() {
  console.log('\n🧪 유료 API 키 테스트...');
  console.log(`🔑 API 키: ${API_KEY.substring(0, 20)}...${API_KEY.substring(API_KEY.length - 10)}\n`);

  const testPrompt = '부산시민공원 봄꽃 축제, 화려한 꽃 조형물, 밝은 분위기';
  const testFilename = 'test_paid_api.png';

  console.log('📝 테스트 프롬프트:', testPrompt);
  console.log('🎨 모델: gemini-2.5-flash-image\n');

  return new Promise((resolve, reject) => {
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
      path: `/v1beta/models/gemini-2.5-flash-image:generateContent?key=${API_KEY}`,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(requestBody)
      }
    };

    console.log('⏳ API 요청 중...\n');

    const req = https.request(options, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        console.log(`📊 HTTP 응답: ${res.statusCode}\n`);

        if (res.statusCode === 200) {
          const result = JSON.parse(data);

          // 응답 구조 출력
          console.log('✅ API 응답 성공!');
          console.log('응답 구조:', JSON.stringify(result, null, 2).substring(0, 500) + '...\n');

          // 이미지 데이터 추출
          const parts = result.candidates?.[0]?.content?.parts;
          if (parts) {
            let imageData = null;
            for (const part of parts) {
              // camelCase (inlineData)
              if (part.inlineData && part.inlineData.data) {
                imageData = part.inlineData.data;
                break;
              }
              // snake_case (inline_data)
              if (part.inline_data && part.inline_data.data) {
                imageData = part.inline_data.data;
                break;
              }
              if (part.image && part.image.data) {
                imageData = part.image.data;
                break;
              }
            }

            if (imageData) {
              // Base64 디코딩 후 저장
              const filepath = path.join(OUTPUT_DIR, testFilename);
              const buffer = Buffer.from(imageData, 'base64');
              fs.writeFileSync(filepath, buffer);

              console.log('🎉 이미지 생성 성공!');
              console.log(`📁 저장 위치: ${filepath}`);
              console.log(`📏 파일 크기: ${(buffer.length / 1024).toFixed(2)} KB\n`);
              console.log('✅ 유료 API 키가 정상 작동합니다!');
              console.log('💰 결제가 활성화되어 있습니다.\n');
              resolve(true);
            } else {
              console.log('⚠️  이미지 데이터를 찾을 수 없습니다.');
              console.log('응답에 inline_data 또는 image 필드가 없습니다.\n');
              resolve(false);
            }
          } else {
            console.log('⚠️  예상과 다른 응답 구조');
            resolve(false);
          }
        } else if (res.statusCode === 429) {
          const error = JSON.parse(data);
          console.log('❌ Quota 초과 오류 (429)');
          console.log('오류 메시지:', error.error?.message || data);
          console.log('\n⚠️  무료 Tier 또는 결제가 활성화되지 않았습니다.');
          console.log('📌 https://console.cloud.google.com/billing 에서 결제 활성화 필요\n');
          resolve(false);
        } else {
          const error = JSON.parse(data);
          console.log(`❌ API 오류 (${res.statusCode})`);
          console.log('오류:', JSON.stringify(error, null, 2));
          console.log('\n');
          reject(new Error(error.error?.message || data));
        }
      });
    });

    req.on('error', (error) => {
      console.error('❌ 요청 실패:', error.message);
      reject(error);
    });

    req.write(requestBody);
    req.end();
  });
}

testPaidAPI()
  .then((success) => {
    if (success) {
      console.log('🚀 전체 이미지 생성 준비 완료!');
      console.log('👉 node generate_images.js 실행하여 10개 이미지 생성 시작\n');
    } else {
      console.log('⚠️  추가 확인이 필요합니다.');
    }
  })
  .catch((error) => {
    console.error('\n❌ 테스트 실패:', error.message);
    process.exit(1);
  });
