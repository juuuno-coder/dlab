// Imagen 3 모델 테스트
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

// 테스트할 모델들
const MODELS = [
  'imagen-3.0-generate-001',
  'imagen-3.0-fast-generate-001',
  'imagen-3.0-capability-preview-0930'
];

async function testImagen3(modelName) {
  console.log(`\n🧪 ${modelName} 테스트 중...\n`);

  const testPrompt = 'A beautiful spring flower festival in a city park, colorful tulips and cherry blossoms, families enjoying the sunny day, photorealistic style';

  return new Promise((resolve, reject) => {
    const requestBody = JSON.stringify({
      prompt: testPrompt,
      number_of_images: 1,
      aspect_ratio: "16:9",
      safety_filter_level: "block_some",
      person_generation: "allow_adult"
    });

    const options = {
      hostname: 'generativelanguage.googleapis.com',
      path: `/v1beta/models/${modelName}:predict?key=${API_KEY}`,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(requestBody)
      }
    };

    const req = https.request(options, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        console.log(`📊 HTTP 응답: ${res.statusCode}\n`);

        if (res.statusCode === 200) {
          try {
            const result = JSON.parse(data);
            console.log('✅ API 응답 성공!');
            console.log('응답 구조:', JSON.stringify(result, null, 2).substring(0, 500) + '...\n');

            // 이미지 데이터 추출 시도
            if (result.predictions && result.predictions[0]) {
              const prediction = result.predictions[0];

              if (prediction.bytesBase64Encoded) {
                const imageData = prediction.bytesBase64Encoded;
                const filename = `test_${modelName.replace(/[^a-z0-9]/g, '_')}.png`;
                const filepath = path.join(OUTPUT_DIR, filename);
                const buffer = Buffer.from(imageData, 'base64');
                fs.writeFileSync(filepath, buffer);

                console.log('🎉 이미지 생성 성공!');
                console.log(`📁 저장 위치: ${filepath}`);
                console.log(`📏 파일 크기: ${(buffer.length / 1024).toFixed(2)} KB\n`);
                resolve({ success: true, model: modelName });
              } else {
                console.log('⚠️  이미지 데이터를 찾을 수 없습니다');
                console.log('응답 구조:', JSON.stringify(result, null, 2));
                resolve({ success: false, model: modelName, reason: 'No image data' });
              }
            } else {
              console.log('⚠️  예상과 다른 응답 구조');
              console.log('응답:', JSON.stringify(result, null, 2));
              resolve({ success: false, model: modelName, reason: 'Unexpected structure' });
            }
          } catch (e) {
            console.log('❌ JSON 파싱 실패:', e.message);
            console.log('원본 응답:', data.substring(0, 500));
            resolve({ success: false, model: modelName, reason: e.message });
          }
        } else if (res.statusCode === 404) {
          console.log('❌ 모델을 찾을 수 없습니다 (404)');
          console.log('이 모델은 사용할 수 없거나 API 키에 권한이 없습니다.\n');
          resolve({ success: false, model: modelName, reason: 'Model not found' });
        } else if (res.statusCode === 403) {
          console.log('❌ 권한 없음 (403)');
          console.log('API 키가 이 모델에 접근할 권한이 없습니다.\n');
          resolve({ success: false, model: modelName, reason: 'Permission denied' });
        } else {
          try {
            const error = JSON.parse(data);
            console.log(`❌ API 오류 (${res.statusCode})`);
            console.log('오류:', JSON.stringify(error, null, 2));
            resolve({ success: false, model: modelName, reason: error.error?.message || 'Unknown error' });
          } catch (e) {
            console.log(`❌ API 오류 (${res.statusCode})`);
            console.log('응답:', data.substring(0, 500));
            resolve({ success: false, model: modelName, reason: data });
          }
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

async function main() {
  console.log('\n🎨 Imagen 3 모델 테스트 시작...\n');
  console.log(`🔑 API 키: ${API_KEY.substring(0, 20)}...${API_KEY.substring(API_KEY.length - 10)}\n`);

  const results = [];

  for (const model of MODELS) {
    const result = await testImagen3(model);
    results.push(result);

    // 성공하면 다른 모델은 테스트 안 함
    if (result.success) {
      console.log(`\n✅ ${model}이(가) 작동합니다!`);
      console.log('이 모델을 사용하여 10개 이미지를 재생성할 수 있습니다.\n');
      break;
    }

    // Rate Limit 방지
    if (MODELS.indexOf(model) < MODELS.length - 1) {
      console.log('⏳ 3초 대기...\n');
      await new Promise(resolve => setTimeout(resolve, 3000));
    }
  }

  console.log('\n📊 테스트 결과 요약:');
  results.forEach(r => {
    console.log(`- ${r.model}: ${r.success ? '✅ 성공' : '❌ 실패 (' + r.reason + ')'}`);
  });

  const successModel = results.find(r => r.success);
  if (successModel) {
    console.log(`\n💡 권장: ${successModel.model}을(를) 사용하세요!`);
  } else {
    console.log('\n⚠️  Imagen 3 모델을 사용할 수 없습니다.');
    console.log('대안: gemini-2.5-flash-image 계속 사용 또는 DALL-E 3 시도\n');
  }
}

main().catch(console.error);
