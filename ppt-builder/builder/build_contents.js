/**
 * PPT빌더 — contents_two_column 빌더
 *
 * 사용법:
 *   node build_contents.js <data.json> <output.pptx>
 *
 * data.json 형식은 schemas/contents_two_column.json의 example_data 참조
 */

const pptxgen = require("pptxgenjs");
const fs = require("fs");

// ── 디자인 시스템 상수 ──────────────────────────────────
const COLORS = {
  header_bg:   "002B5B",
  accent_red:  "C8102E",
  navy:        "002B5B",
  blue:        "004c8c",
  red:         "C8102E",
  gray:        "6B7280",
  num_bg:      "f3f6f9",
  title:       "111111",
  body:        "4B5563",
  muted:       "6B7280",
  footer_bg:   "f3f4f6",
  white:       "FFFFFF",
  border:      "e5e7eb"
};

const FONT = "Noto Sans KR";

// ── 레이아웃 상수 (인치, 13.33 x 7.5 캔버스) ───────────
const SLIDE_W = 13.33;
const SLIDE_H = 7.5;
const HEADER_H = 0.99;
const FOOTER_H = 0.33;
const FOOTER_Y = SLIDE_H - FOOTER_H;
const MARGIN_X = 0.5;
const CONTENT_Y = 1.25;
const CONTENT_H = FOOTER_Y - CONTENT_Y - 0.15;
const COL_GAP = 0.35;
const COL_W = (SLIDE_W - MARGIN_X * 2 - COL_GAP) / 2;
const LEFT_X = MARGIN_X;
const RIGHT_X = MARGIN_X + COL_W + COL_GAP;
const CARD_GAP = 0.2;
const CARD_BORDER = 0.05;
const NUM_W = 0.66;

// ── 액센트 색상 매핑 ────────────────────────────────────
function accentColor(accent) {
  return COLORS[accent] || COLORS.navy;
}

// ── 카드 그리기 ─────────────────────────────────────────
function drawCard(slide, section, x, y, w, h) {
  const accent = accentColor(section.accent);

  // 카드 배경 + 그림자
  slide.addShape("rect", {
    x, y, w, h,
    fill: { color: COLORS.white },
    shadow: { type: "outer", color: "000000", blur: 6, offset: 2, angle: 135, opacity: 0.08 },
    rectRadius: 0.06
  });

  // 왼쪽 액센트 바
  slide.addShape("rect", {
    x, y, w: CARD_BORDER, h,
    fill: { color: accent }
  });

  // 넘버 영역
  slide.addShape("rect", {
    x: x + CARD_BORDER, y, w: NUM_W, h,
    fill: { color: COLORS.num_bg }
  });
  slide.addText(section.num, {
    x: x + CARD_BORDER, y, w: NUM_W, h,
    fontSize: 26, fontFace: FONT, bold: true, color: accent,
    align: "center", valign: "middle", margin: 0
  });

  // 제목 + 페이지
  const textX = x + CARD_BORDER + NUM_W + 0.15;
  const textW = w - CARD_BORDER - NUM_W - 0.3;

  slide.addText(section.title, {
    x: textX, y: y + 0.12, w: textW * 0.65, h: 0.35,
    fontSize: 18, fontFace: FONT, bold: true, color: COLORS.title,
    margin: 0, valign: "middle"
  });
  slide.addText(section.pages, {
    x: textX + textW * 0.65, y: y + 0.12, w: textW * 0.35, h: 0.35,
    fontSize: 13, fontFace: FONT, color: COLORS.muted,
    align: "right", margin: 0, valign: "middle"
  });

  // 하위 항목
  if (section.items && section.items.length > 0) {
    const itemTexts = section.items.map((item, i) => ({
      text: item,
      options: {
        fontSize: 12, fontFace: FONT, color: COLORS.body,
        breakLine: i < section.items.length - 1
      }
    }));
    slide.addText(itemTexts, {
      x: textX, y: y + 0.45, w: textW, h: h - 0.55,
      valign: "top", margin: 0, lineSpacingMultiple: 1.4
    });
  }
}

// ── 메인 빌드 함수 ──────────────────────────────────────
function buildContentsSlide(data) {
  const pres = new pptxgen();
  pres.layout = "LAYOUT_WIDE";  // 13.33 x 7.5
  pres.author = "PPT빌더";

  const slide = pres.addSlide();

  // 1. 헤더 배경
  slide.addShape("rect", {
    x: 0, y: 0, w: SLIDE_W, h: HEADER_H,
    fill: { color: COLORS.header_bg }
  });

  // 헤더 데코 (우측 삼각형)
  // pptxgenjs doesn't support clip-path, use a subtle accent shape
  slide.addShape("rect", {
    x: SLIDE_W - 2.5, y: 0, w: 2.5, h: HEADER_H,
    fill: { color: COLORS.accent_red, transparency: 90 }
  });

  // 헤더 타이틀
  slide.addText("CONTENTS", {
    x: MARGIN_X, y: 0.15, w: 5, h: 0.7,
    fontSize: 36, fontFace: FONT, bold: true, color: COLORS.white,
    margin: 0
  });

  // 2. 섹션 카드 배치
  const leftSections = data.sections.filter(s => s.column === "left");
  const rightSections = data.sections.filter(s => s.column === "right");

  function drawColumn(sections, colX) {
    const totalFlex = sections.reduce((sum, s) => sum + (s.flex || 1), 0);
    const totalGap = (sections.length - 1) * CARD_GAP;
    const availH = CONTENT_H - totalGap;

    let currentY = CONTENT_Y;
    sections.forEach((section, i) => {
      const flex = section.flex || 1;
      const cardH = (flex / totalFlex) * availH;
      drawCard(slide, section, colX, currentY, COL_W, cardH);
      currentY += cardH + CARD_GAP;
    });
  }

  drawColumn(leftSections, LEFT_X);
  drawColumn(rightSections, RIGHT_X);

  // 3. 푸터
  slide.addShape("rect", {
    x: 0, y: FOOTER_Y, w: SLIDE_W, h: FOOTER_H,
    fill: { color: COLORS.footer_bg },
    line: { color: COLORS.border, width: 0.5 }
  });
  slide.addText(String(data.page_number || 2), {
    x: SLIDE_W - 1, y: FOOTER_Y, w: 0.5, h: FOOTER_H,
    fontSize: 11, fontFace: FONT, color: COLORS.muted,
    align: "right", valign: "middle", margin: 0
  });

  return pres;
}

// ── CLI 실행 ────────────────────────────────────────────
const args = process.argv.slice(2);
if (args.length < 2) {
  console.log("사용법: node build_contents.js <data.json> <output.pptx>");
  console.log("  data.json: sections 배열이 포함된 JSON 파일");
  console.log("  output.pptx: 출력 파일 경로");
  process.exit(1);
}

const data = JSON.parse(fs.readFileSync(args[0], "utf-8"));
const outputPath = args[1];

const pres = buildContentsSlide(data);
pres.writeFile({ fileName: outputPath }).then(() => {
  console.log(`✅ 생성 완료: ${outputPath}`);
}).catch(err => {
  console.error("❌ 생성 실패:", err.message);
  process.exit(1);
});
