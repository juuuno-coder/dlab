// HTML 슬라이드에 생성된 이미지 통합
const fs = require('fs');
const path = require('path');

const HTML_PATH = path.join(__dirname, 'public', '2026_부산봄꽃전시회_제안서.html');
const OUTPUT_PATH = path.join(__dirname, 'public', '2026_부산봄꽃전시회_제안서_with_images.html');
const IMAGE_DIR = '/proposal_images';

console.log('\n📝 HTML에 이미지 통합 시작...\n');

// HTML 읽기
let html = fs.readFileSync(HTML_PATH, 'utf-8');

// 이미지 매핑 정보
const imageIntegrations = [
  {
    slideNumber: 1,
    filename: 'slide_01_1.png',
    insertType: 'background',
    description: '표지 KEY VISUAL'
  },
  {
    slideNumber: 3,
    filename: 'slide_03_1.png',
    insertType: 'background',
    description: 'Part I 배경'
  },
  {
    slideNumber: 4,
    filenames: ['slide_04_1.png', 'slide_04_2.png', 'slide_04_3.png'],
    insertType: 'content',
    description: '사업 배경 이미지 3개'
  },
  {
    slideNumber: 11,
    filenames: ['slide_11_1.png', 'slide_11_2.png', 'slide_11_3.png'],
    insertType: 'content',
    description: '조형물 렌더링 3개'
  },
  {
    slideNumber: 12,
    filename: 'slide_12_1.png',
    insertType: 'content',
    description: '테마 화단 조감도'
  },
  {
    slideNumber: 27,
    filename: 'slide_27_1.png',
    insertType: 'content',
    description: '행사장 평면도'
  }
];

// CSS 스타일 추가 (이미지용)
const imageStyles = `
    /* 이미지 스타일 */
    .slide-image {
      max-width: 100%;
      height: auto;
      border-radius: 8px;
      box-shadow: 0 4px 16px rgba(0,0,0,0.1);
      margin: 30px 0;
    }

    .image-grid {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 30px;
      margin: 40px 0;
    }

    .image-grid img {
      width: 100%;
      height: 280px;
      object-fit: cover;
      border-radius: 8px;
      box-shadow: 0 4px 16px rgba(0,0,0,0.1);
    }

    .slide.cover {
      background-size: cover;
      background-position: center;
      background-repeat: no-repeat;
    }

    .slide.cover::after {
      content: '';
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: linear-gradient(135deg, rgba(255,105,180,0.7) 0%, rgba(152,216,200,0.7) 100%);
      z-index: 0;
    }

    .slide.cover .subtitle,
    .slide.cover .title,
    .slide.cover .info {
      position: relative;
      z-index: 1;
    }
`;

// CSS 삽입 (</style> 태그 앞에)
html = html.replace('</style>', `${imageStyles}\n  </style>`);

console.log('✅ CSS 스타일 추가 완료');

// 슬라이드 번호로 HTML 분할 (간단한 방법)
// 실제 슬라이드 구조를 파악하고 이미지 삽입
let slideCount = 0;

// 슬라이드 1: 표지 배경 이미지
html = html.replace(
  '<div class="slide cover">',
  `<div class="slide cover" style="background-image: url('${IMAGE_DIR}/slide_01_1.png');">`
);
console.log('✅ 슬라이드 1 (표지): 배경 이미지 적용');

// 슬라이드 3: Part I 배경 (chapter 클래스 찾기)
// Part I. 제안개요가 있는 슬라이드에 배경 추가
const partIRegex = /(<div class="slide chapter">[\s\S]*?<div class="title">Part I\. 제안개요<\/div>)/;
if (partIRegex.test(html)) {
  html = html.replace(
    partIRegex,
    (match) => match.replace(
      '<div class="slide chapter">',
      `<div class="slide chapter" style="background-image: url('${IMAGE_DIR}/slide_03_1.png'); background-size: cover; background-position: center; background-blend-mode: overlay;">`
    )
  );
  console.log('✅ 슬라이드 3 (Part I): 배경 이미지 적용');
}

// 슬라이드 4: 사업 배경 및 필요성 (3개 이미지 추가)
const slide4Regex = /(<div class="slide-title">사업 배경 및 필요성<\/div>[\s\S]*?<div class="content">)([\s\S]*?)(<\/div>\s*<\/div>)/;
if (slide4Regex.test(html)) {
  html = html.replace(
    slide4Regex,
    (match, before, content, after) => {
      const imageGrid = `
      <div class="image-grid">
        <img src="${IMAGE_DIR}/slide_04_1.png" alt="제5회 봄꽃 축제 성공 사례">
        <img src="${IMAGE_DIR}/slide_04_2.png" alt="부산 화훼 농가">
        <img src="${IMAGE_DIR}/slide_04_3.png" alt="시민공원 어린이 백사장">
      </div>
      ${content}
      `;
      return before + imageGrid + after;
    }
  );
  console.log('✅ 슬라이드 4 (사업 배경): 이미지 3개 추가');
}

// 슬라이드 11: 조형물 설치 계획 (3개 렌더링 추가)
// "조형물" 또는 "Part II" 관련 슬라이드 찾기 - 정확한 제목 확인 필요
const slide11Regex = /(<div class="slide-title">.*조형물.*<\/div>[\s\S]*?<div class="content">)([\s\S]*?)(<\/div>\s*<\/div>)/;
if (slide11Regex.test(html)) {
  html = html.replace(
    slide11Regex,
    (match, before, content, after) => {
      const imageGrid = `
      <div class="image-grid">
        <img src="${IMAGE_DIR}/slide_11_1.png" alt="동물 조형물 (토끼, 곰, 사슴)">
        <img src="${IMAGE_DIR}/slide_11_2.png" alt="대형 꽃 아치 게이트">
        <img src="${IMAGE_DIR}/slide_11_3.png" alt="부기 대형 조형물">
      </div>
      ${content}
      `;
      return before + imageGrid + after;
    }
  );
  console.log('✅ 슬라이드 11 (조형물): 이미지 3개 추가');
} else {
  console.log('⚠️  슬라이드 11 (조형물): 제목 매칭 실패, 수동 확인 필요');
}

// 슬라이드 12: 테마 화단 (1개 조감도)
const slide12Regex = /(<div class="slide-title">.*화단.*<\/div>[\s\S]*?<div class="content">)([\s\S]*?)(<\/div>\s*<\/div>)/;
if (slide12Regex.test(html)) {
  html = html.replace(
    slide12Regex,
    (match, before, content, after) => {
      const image = `<img src="${IMAGE_DIR}/slide_12_1.png" alt="봄꽃 테마 화단 조감도" class="slide-image">\n      ${content}`;
      return before + image + after;
    }
  );
  console.log('✅ 슬라이드 12 (테마 화단): 조감도 이미지 추가');
} else {
  console.log('⚠️  슬라이드 12 (화단): 제목 매칭 실패, 수동 확인 필요');
}

// 슬라이드 27: 행사장 배치도 (1개 평면도)
const slide27Regex = /(<div class="slide-title">.*배치.*<\/div>[\s\S]*?<div class="content">)([\s\S]*?)(<\/div>\s*<\/div>)/;
if (slide27Regex.test(html)) {
  html = html.replace(
    slide27Regex,
    (match, before, content, after) => {
      const image = `<img src="${IMAGE_DIR}/slide_27_1.png" alt="행사장 평면도 배치도" class="slide-image">\n      ${content}`;
      return before + image + after;
    }
  );
  console.log('✅ 슬라이드 27 (배치도): 평면도 이미지 추가');
} else {
  console.log('⚠️  슬라이드 27 (배치도): 제목 매칭 실패, 수동 확인 필요');
}

// 결과 저장
fs.writeFileSync(OUTPUT_PATH, html, 'utf-8');

console.log('\n✅ 완료!');
console.log(`📁 저장 위치: ${OUTPUT_PATH}`);
console.log('\n다음 단계:');
console.log('1. 브라우저로 파일 열기: file:///${OUTPUT_PATH.replace(/\\/g, '/')}');
console.log('2. 이미지가 제대로 표시되는지 확인');
console.log('3. PPTX 변환 (필요 시)\n');
