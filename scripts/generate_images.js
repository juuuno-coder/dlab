// 제안서 이미지 자동 생성 스크립트
// Google AI Nano Banana Pro (나노바나나 Pro) 사용

const fs = require('fs');
const path = require('path');
const https = require('https');

// .env 파일 직접 읽기 (프로젝트 루트에 위치)
const envPath = path.join(__dirname, '..', '.env');
let API_KEY = process.env.GOOGLE_GENERATIVE_AI_API_KEY;

if (!API_KEY && fs.existsSync(envPath)) {
  const envContent = fs.readFileSync(envPath, 'utf-8');
  const match = envContent.match(/GOOGLE_GENERATIVE_AI_API_KEY=(.+)/);
  if (match) {
    API_KEY = match[1].trim();
  }
}
// 프로젝트명을 CLI 인자로 받음 (기본값: 리멘_부산봄꽃전시회_2026)
// 사용법: node scripts/generate_images.js 리멘_부산봄꽃전시회_2026
const PROJECT_NAME = process.argv[2] || '리멘_부산봄꽃전시회_2026';
const OUTPUT_DIR = path.join(__dirname, '..', 'public', 'projects', PROJECT_NAME, 'images');

// 출력 디렉토리 생성
if (!fs.existsSync(OUTPUT_DIR)) {
  fs.mkdirSync(OUTPUT_DIR, { recursive: true });
}

// 우선순위 이미지 프롬프트 (개선된 영어 버전 - 고품질)
const priorityPrompts = [
  {
    filename: 'slide_01_1.png',
    prompt: 'Professional photograph of a vibrant spring flower festival entrance at Busan Citizen Park, featuring elaborate floral sculptures and colorful topiaries, cherry blossoms in full bloom, warm golden hour sunlight, happy families walking through the entrance, pastel pink and mint green color palette, bright and lively atmosphere, photorealistic style, ultra-detailed, 8K quality, 16:9 aspect ratio'
  },
  {
    filename: 'slide_03_1.png',
    prompt: 'Aerial view of Busan Citizen Park in spring season, beautiful landscape with blooming flowers covering the grounds, cherry blossom trees, wide green lawns, warm sunlight, soft pastel pink filter overlay, shallow depth of field for background use, dreamy atmosphere, professional photography, 4K quality, 16:9 aspect ratio'
  },
  {
    filename: 'slide_04_1.png',
    prompt: 'Successful spring flower festival scene in Busan, large crowd of visitors enjoying the event, families taking photos in front of colorful flower sculptures, vibrant tulips and roses, cheerful atmosphere, warm sunny day, photorealistic style, professional event photography, sharp focus, vivid colors, 16:9 aspect ratio'
  },
  {
    filename: 'slide_04_2.png',
    prompt: 'Interior of a modern flower greenhouse in Busan, rows of colorful blooming flowers including tulips, roses, and gerberas, professional horticulture setup, warm natural light streaming through glass ceiling, farmer tending to flowers, vibrant and fresh atmosphere, photorealistic style, ultra-detailed, 16:9 aspect ratio'
  },
  {
    filename: 'slide_04_3.png',
    prompt: 'Busan Citizen Park white sand beach area in spring season, beautiful spring landscape with blooming flowers along the walking paths, families enjoying outdoor activities, warm sunny weather, green lawns and cherry blossom trees, peaceful atmosphere, professional photography, natural colors, 16:9 aspect ratio'
  },
  {
    filename: 'slide_11_1.png',
    prompt: 'Cute animal topiary sculptures made of colorful flowers at child eye level, featuring rabbit, bear, and deer designs, decorated with pastel-colored petals and greenery, spring garden setting, bright sunny day, cheerful and whimsical atmosphere, photorealistic 3D render, ultra-detailed, vibrant colors, 16:9 aspect ratio'
  },
  {
    filename: 'slide_11_2.png',
    prompt: 'Large floral arch gateway at park entrance, elaborate design made of roses and tulips, perfect for photo opportunities, romantic and elegant atmosphere, surrounded by spring flowers, warm golden hour lighting, photorealistic style, professional architecture photography, ultra-detailed, 16:9 aspect ratio'
  },
  {
    filename: 'slide_11_3.png',
    prompt: 'Large Bugi mascot sculpture (Busan city mascot) decorated with colorful flowers, standing as a landmark centerpiece at the festival center, adorable and eye-catching design, surrounded by spring garden, bright sunny day, families taking photos, photorealistic 3D render, ultra-detailed, vibrant colors, 16:9 aspect ratio'
  },
  {
    filename: 'slide_12_1.png',
    prompt: 'Birds-eye view of decorative flower garden beds with intricate patterns, colorful spring flowers arranged in beautiful designs, various sections with different color themes, professional landscape design, aerial photography perspective, vibrant and detailed, sunny day, photorealistic style, 8K quality, 16:9 aspect ratio'
  },
  {
    filename: 'slide_27_1.png',
    prompt: 'Festival venue layout map of Busan Citizen Park, professional floor plan illustration showing different zones - sculpture area in pink, flower garden area in mint green, experience booth area in lavender, stage area in gold, clear pathways and landmarks, top-down view, clean infographic style with soft colors, professional design, 16:9 aspect ratio'
  }
];

// Google Gemini 2.5 Flash Image API 호출
async function generateImageWithNanoBanana(prompt, filename) {
  return new Promise((resolve, reject) => {
    const requestBody = JSON.stringify({
      contents: [{
        parts: [{
          text: prompt
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

    const req = https.request(options, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        if (res.statusCode === 200) {
          const result = JSON.parse(data);

          // 이미지 데이터 추출
          const imageData = extractImageData(result);

          if (imageData) {
            // Base64 디코딩 후 저장
            saveBase64Image(imageData, filename)
              .then(() => resolve({ success: true, filename }))
              .catch(reject);
          } else {
            reject(new Error('이미지 데이터를 찾을 수 없습니다'));
          }
        } else {
          const error = JSON.parse(data);
          reject(new Error(`API 오류 (${res.statusCode}): ${error.error?.message || data}`));
        }
      });
    });

    req.on('error', reject);
    req.write(requestBody);
    req.end();
  });
}

// 이미지 데이터 추출
function extractImageData(result) {
  const parts = result.candidates?.[0]?.content?.parts;
  if (!parts) return null;

  for (const part of parts) {
    // camelCase (inlineData) - Gemini 2.5
    if (part.inlineData && part.inlineData.data) {
      return part.inlineData.data;
    }
    // snake_case (inline_data) - 이전 버전
    if (part.inline_data && part.inline_data.data) {
      return part.inline_data.data;
    }
    if (part.image && part.image.data) {
      return part.image.data;
    }
  }

  return null;
}

// Base64 이미지 저장
function saveBase64Image(base64Data, filename) {
  return new Promise((resolve, reject) => {
    try {
      const filepath = path.join(OUTPUT_DIR, filename);
      const buffer = Buffer.from(base64Data, 'base64');
      fs.writeFileSync(filepath, buffer);
      console.log(`✅ 저장 완료: ${filename}`);
      resolve();
    } catch (error) {
      reject(error);
    }
  });
}

// 이미지 다운로드
function downloadImage(url, filename) {
  return new Promise((resolve, reject) => {
    const filepath = path.join(OUTPUT_DIR, filename);
    const file = fs.createWriteStream(filepath);

    https.get(url, (response) => {
      response.pipe(file);
      file.on('finish', () => {
        file.close();
        console.log(`✅ 저장 완료: ${filename}`);
        resolve();
      });
    }).on('error', (err) => {
      fs.unlink(filepath, () => {});
      reject(err);
    });
  });
}

// 메인 실행
async function main() {
  console.log('\n🎨 제안서 이미지 자동 생성 시작...');
  console.log('🤖 모델: Google Nano Banana Pro (나노바나나 프로)\n');

  if (!API_KEY) {
    console.error('❌ API 키가 없습니다!');
    console.error('📌 .env 파일에 GOOGLE_GENERATIVE_AI_API_KEY를 추가하세요.');
    process.exit(1);
  }

  console.log(`📁 출력 폴더: ${OUTPUT_DIR}`);
  console.log(`📊 총 ${priorityPrompts.length}개 이미지 생성\n`);

  let successCount = 0;
  let failCount = 0;

  for (let i = 0; i < priorityPrompts.length; i++) {
    const item = priorityPrompts[i];
    console.log(`\n[${i + 1}/${priorityPrompts.length}] ${item.filename}`);
    console.log(`📝 프롬프트: ${item.prompt.substring(0, 50)}...`);

    try {
      await generateImageWithNanoBanana(item.prompt, item.filename);
      successCount++;

      // Rate Limit 방지 (Google API는 분당 60개 제한)
      if (i < priorityPrompts.length - 1) {
        console.log('⏳ 3초 대기 (Rate Limit 방지)...');
        await new Promise(resolve => setTimeout(resolve, 3000));
      }
    } catch (error) {
      console.error(`❌ 실패: ${error.message}`);
      failCount++;

      // 오류 시 조금 더 대기
      if (i < priorityPrompts.length - 1) {
        console.log('⏳ 5초 추가 대기...');
        await new Promise(resolve => setTimeout(resolve, 5000));
      }
    }
  }

  console.log('\n\n✅ 완료!');
  console.log(`성공: ${successCount}개`);
  console.log(`실패: ${failCount}개`);
  console.log(`\n📁 이미지 저장 위치: ${OUTPUT_DIR}\n`);
}

main().catch(console.error);
