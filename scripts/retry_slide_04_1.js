// slide_04_1.png 재시도
const https = require('https');
const fs = require('fs');
const path = require('path');

const API_KEY = 'AIzaSyATotK7r1e1htzO9WUag2qLHCOQAY7srFg';
// 프로젝트명을 CLI 인자로 받음 (기본값: 리멘_부산봄꽃전시회_2026)
const PROJECT_NAME = process.argv[2] || '리멘_부산봄꽃전시회_2026';
const OUTPUT_DIR = path.join(__dirname, '..', 'public', 'projects', PROJECT_NAME, 'images');

const prompt = 'Generate an image: Successful Busan 5th Spring Flower Festival, many visitors enjoying the festival, families taking photos in front of colorful flower sculptures, bright and cheerful atmosphere, warm spring sunlight, festival outdoor scene, realistic style';
const filename = 'slide_04_1.png';

console.log('\n🔄 실패한 이미지 재시도 (영어 프롬프트)...');
console.log('📝 프롬프트:', prompt);

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
  res.on('data', (chunk) => { data += chunk; });
  res.on('end', () => {
    if (res.statusCode === 200) {
      const result = JSON.parse(data);
      const parts = result.candidates?.[0]?.content?.parts;

      if (parts) {
        let imageData = null;
        for (const part of parts) {
          if (part.inlineData && part.inlineData.data) {
            imageData = part.inlineData.data;
            break;
          }
          if (part.inline_data && part.inline_data.data) {
            imageData = part.inline_data.data;
            break;
          }
        }

        if (imageData) {
          const filepath = path.join(OUTPUT_DIR, filename);
          const buffer = Buffer.from(imageData, 'base64');
          fs.writeFileSync(filepath, buffer);
          console.log(`✅ 저장 완료: ${filename} (${(buffer.length / 1024).toFixed(2)} KB)`);
        } else {
          console.log('❌ 이미지 데이터를 찾을 수 없습니다');
          console.log('응답 구조:', JSON.stringify(result, null, 2).substring(0, 500));
        }
      } else {
        console.log('❌ parts가 없습니다');
        console.log('응답:', JSON.stringify(result, null, 2));
      }
    } else {
      const error = JSON.parse(data);
      console.error(`❌ API 오류 (${res.statusCode}):`, error.error?.message || data);
    }
  });
});

req.on('error', (err) => console.error('❌ 요청 실패:', err.message));
req.write(requestBody);
req.end();
