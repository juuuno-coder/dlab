// Google AI API 사용 가능한 모델 목록 확인
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

async function listModels() {
  console.log('📋 Google AI API 사용 가능한 모델 목록 조회...\n');

  if (!API_KEY) {
    console.error('❌ API 키가 없습니다!');
    process.exit(1);
  }

  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'generativelanguage.googleapis.com',
      path: `/v1beta/models?key=${API_KEY}`,
      method: 'GET',
      headers: {
        'Content-Type': 'application/json'
      }
    };

    const req = https.request(options, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        if (res.statusCode === 200) {
          const result = JSON.parse(data);

          console.log('✅ 모델 목록 조회 성공!\n');

          if (result.models) {
            console.log(`총 ${result.models.length}개 모델 발견:\n`);

            result.models.forEach((model, index) => {
              console.log(`${index + 1}. ${model.name}`);
              console.log(`   설명: ${model.description || 'N/A'}`);
              console.log(`   지원 메서드: ${model.supportedGenerationMethods?.join(', ') || 'N/A'}`);

              // Imagen 관련 모델 강조
              if (model.name.toLowerCase().includes('imagen') ||
                  model.name.toLowerCase().includes('image') ||
                  model.description?.toLowerCase().includes('image generation')) {
                console.log('   🎨 ** 이미지 생성 모델! **');
              }
              console.log('');
            });

            // Imagen 모델 찾기
            const imageModels = result.models.filter(m =>
              m.name.toLowerCase().includes('imagen') ||
              m.name.toLowerCase().includes('image') ||
              m.supportedGenerationMethods?.includes('generateImage')
            );

            if (imageModels.length > 0) {
              console.log('\n🎉 이미지 생성 가능한 모델 발견!');
              imageModels.forEach(m => {
                console.log(`\n모델: ${m.name}`);
                console.log(`메서드: ${m.supportedGenerationMethods.join(', ')}`);
              });
            } else {
              console.log('\n⚠️  이미지 생성 모델을 찾을 수 없습니다.');
              console.log('💡 하지만 Google AI Studio UI에서는 가능할 수 있습니다.');
            }
          }

          resolve(result);
        } else {
          console.error(`❌ API 오류: ${res.statusCode}`);
          console.error(data);
          reject(new Error(data));
        }
      });
    });

    req.on('error', (error) => {
      console.error('❌ 요청 실패:', error.message);
      reject(error);
    });

    req.end();
  });
}

listModels()
  .then(() => {
    console.log('\n✅ 완료!');
  })
  .catch((error) => {
    console.error('\n❌ 실패:', error.message);
    process.exit(1);
  });
