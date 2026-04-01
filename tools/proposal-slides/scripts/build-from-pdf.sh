#!/bin/bash
# PDF → 메타데이터 → HTML 전체 과정 자동화 스크립트

set -e  # 오류 발생 시 즉시 중단

# 색상 코드
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 사용법 출력
usage() {
    echo "사용법: $0 <pdf_path> <output_dir> [title] [client] [date]"
    echo ""
    echo "예시:"
    echo "  $0 proposal.pdf ./limen-bidding"
    echo "  $0 proposal.pdf ./limen-bidding \"봄꽃 전시회\" \"부산광역시\" \"2026-02-24\""
    echo ""
    exit 1
}

# 인자 확인
if [ "$#" -lt 2 ]; then
    usage
fi

PDF_PATH="$1"
OUTPUT_DIR="$2"
TITLE="${3:-제안서}"
CLIENT="${4:-}"
DATE="${5:-}"

# PDF 파일 존재 확인
if [ ! -f "$PDF_PATH" ]; then
    echo -e "${RED}[ERR]${NC} PDF 파일을 찾을 수 없습니다: $PDF_PATH"
    exit 1
fi

# 절대 경로 변환 (Windows 경로 처리)
PDF_ABS=$(realpath "$PDF_PATH")
OUTPUT_ABS=$(realpath -m "$OUTPUT_DIR")

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  PDF → HTML 제안서 자동 생성 시작${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  PDF: ${YELLOW}$PDF_PATH${NC}"
echo -e "  출력: ${YELLOW}$OUTPUT_DIR${NC}"
echo -e "  제목: ${YELLOW}$TITLE${NC}"
echo -e "  클라이언트: ${YELLOW}$CLIENT${NC}"
echo -e "  날짜: ${YELLOW}$DATE${NC}"
echo ""

# 출력 디렉토리 생성
mkdir -p "$OUTPUT_DIR/analysis/pages"
mkdir -p "$OUTPUT_DIR/output"

# Step 1: PDF 페이지 추출
echo -e "${GREEN}[Step 1/4]${NC} PDF 페이지 추출 중..."
python tools/pdf-analyzer/extract_pages.py "$PDF_ABS" "$OUTPUT_ABS/analysis/pages" 2

# Step 2: 레이아웃 분석
echo ""
echo -e "${GREEN}[Step 2/4]${NC} 레이아웃 분석 중..."
python tools/pdf-analyzer/analyze_layout.py "$PDF_ABS" "$OUTPUT_ABS/analysis/layout.json"

# Step 3: 메타데이터 생성
echo ""
echo -e "${GREEN}[Step 3/4]${NC} 메타데이터 생성 중..."
python tools/pdf-analyzer/generate_metadata.py \
    "$OUTPUT_ABS/analysis/layout.json" \
    "$OUTPUT_ABS/analysis/metadata.json" \
    "$TITLE" \
    "$CLIENT" \
    "$DATE"

# Step 4: HTML 생성 (proposal-slides가 준비되면 활성화)
echo ""
echo -e "${GREEN}[Step 4/4]${NC} HTML 생성..."
echo -e "${YELLOW}[INFO]${NC} proposal-slides 시스템 확장 후 활성화 예정"
# TODO: Phase 2 완료 후 활성화
# cd ../../dlab/tools/proposal-slides
# node dist/index.js \
#     --metadata "$OUTPUT_ABS/analysis/metadata.json" \
#     --output "$OUTPUT_ABS/output/proposal.html" \
#     --design limen-bidding

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  ✅ 제안서 분석 완료!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "📁 출력 파일:"
echo -e "  이미지: ${YELLOW}$OUTPUT_DIR/analysis/pages/${NC}"
echo -e "  레이아웃: ${YELLOW}$OUTPUT_DIR/analysis/layout.json${NC}"
echo -e "  메타데이터: ${YELLOW}$OUTPUT_DIR/analysis/metadata.json${NC}"
echo ""
echo -e "다음 단계:"
echo -e "  1. ${YELLOW}$OUTPUT_DIR/analysis/metadata.json${NC} 확인"
echo -e "  2. proposal-slides 시스템 확장 (Phase 2)"
echo -e "  3. HTML 생성 및 검증"
echo ""
