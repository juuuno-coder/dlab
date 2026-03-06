"""
고급 PDF 분석 도구
- PDF 각 페이지의 레이아웃, 텍스트, 스타일 정보 추출
- 페이지 타입 자동 분류
- HTML 생성을 위한 구조화된 JSON 출력
"""

import sys
import json
from pathlib import Path
import pdfplumber
from pdf2image import convert_from_path
import re

class AdvancedPDFAnalyzer:
    def __init__(self, pdf_path):
        self.pdf_path = Path(pdf_path)
        self.pdf = pdfplumber.open(pdf_path)
        self.analysis = {
            'metadata': {},
            'pages': []
        }

    def analyze_page_type(self, page_num, text_content, page_obj):
        """페이지 타입 분류"""
        text_lower = text_content.lower()

        # 표지 페이지
        if page_num == 1 and ('제안서' in text_content or '제 안 서' in text_content):
            return 'cover'

        # 목차 페이지
        if 'ⅰ.' in text_lower or 'ⅱ.' in text_lower or 'ⅲ.' in text_lower:
            if page_num <= 3:
                return 'toc'

        # 구분 페이지 (Part 시작)
        if 'part' in text_lower and len(text_content.split('\n')) < 15:
            return 'divider'

        # 표가 있는 페이지
        tables = page_obj.find_tables()
        if tables and len(tables) > 0:
            return 'content_table'

        # 리스트가 많은 페이지
        bullet_count = text_content.count('•') + text_content.count('-')
        if bullet_count > 3:
            return 'content_list'

        # 일반 콘텐츠
        return 'content_text'

    def extract_text_blocks(self, page_obj):
        """텍스트 블록 추출 (위치 정보 포함)"""
        words = page_obj.extract_words()

        if not words:
            return []

        # Y 좌표 기준으로 그룹화 (같은 줄)
        lines = {}
        for word in words:
            y = round(word['top'], 1)
            if y not in lines:
                lines[y] = []
            lines[y].append(word)

        # 각 줄을 텍스트 블록으로 변환
        blocks = []
        for y in sorted(lines.keys()):
            line_words = sorted(lines[y], key=lambda w: w['x0'])
            text = ' '.join([w['text'] for w in line_words])

            blocks.append({
                'text': text,
                'y': y,
                'x': line_words[0]['x0'],
                'height': line_words[0]['height'],
                'fontname': line_words[0].get('fontname', ''),
                'size': round(line_words[0]['height'], 1)
            })

        return blocks

    def extract_tables(self, page_obj):
        """표 정보 추출"""
        tables = page_obj.find_tables()

        result = []
        for table in tables:
            extracted = table.extract()
            if extracted:
                result.append({
                    'bbox': table.bbox,
                    'data': extracted
                })

        return result

    def analyze_page(self, page_num):
        """단일 페이지 분석"""
        page = self.pdf.pages[page_num - 1]

        # 기본 정보
        text = page.extract_text() or ''

        # 페이지 타입 분류
        page_type = self.analyze_page_type(page_num, text, page)

        # 텍스트 블록 추출
        text_blocks = self.extract_text_blocks(page)

        # 표 추출
        tables = self.extract_tables(page)

        # Part 정보 추출
        part_match = re.search(r'Part [IⅠⅡⅢⅣ]+\.?\s*(.+)', text)
        part_info = part_match.group(0) if part_match else None

        # 섹션 제목 추출 (숫자로 시작하는 줄)
        section_titles = []
        for block in text_blocks[:10]:  # 상위 10개 블록만 확인
            if re.match(r'^\d+\.', block['text']) or re.match(r'^\d+\)', block['text']):
                section_titles.append(block['text'])

        return {
            'page_number': page_num,
            'page_type': page_type,
            'part': part_info,
            'section_titles': section_titles,
            'text_blocks': text_blocks,
            'tables': tables,
            'full_text': text,
            'dimensions': {
                'width': page.width,
                'height': page.height
            }
        }

    def analyze_all(self):
        """전체 PDF 분석"""
        total_pages = len(self.pdf.pages)

        print(f"PDF 분석 시작: {self.pdf_path.name}")
        print(f"총 {total_pages}페이지")
        print("="*80)

        for page_num in range(1, total_pages + 1):
            print(f"분석 중: {page_num}/{total_pages}", end='\r')

            page_analysis = self.analyze_page(page_num)
            self.analysis['pages'].append(page_analysis)

        print(f"\n분석 완료!")

        # 메타데이터 추가
        self.analysis['metadata'] = {
            'total_pages': total_pages,
            'file_name': self.pdf_path.name,
            'file_path': str(self.pdf_path)
        }

        return self.analysis

    def save_analysis(self, output_path):
        """분석 결과를 JSON으로 저장"""
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(self.analysis, f, ensure_ascii=False, indent=2)

        print(f"분석 결과 저장: {output_path}")

    def print_summary(self):
        """분석 요약 출력"""
        print("\n" + "="*80)
        print("페이지 타입 분포:")
        print("="*80)

        type_counts = {}
        for page in self.analysis['pages']:
            ptype = page['page_type']
            type_counts[ptype] = type_counts.get(ptype, 0) + 1

        for ptype, count in sorted(type_counts.items()):
            print(f"{ptype:20s}: {count:3d}페이지")

        print("\n" + "="*80)
        print("Part 구조:")
        print("="*80)

        current_part = None
        for page in self.analysis['pages']:
            if page['part'] and page['part'] != current_part:
                current_part = page['part']
                print(f"\n페이지 {page['page_number']:2d}: {current_part}")
                if page['section_titles']:
                    for title in page['section_titles'][:3]:
                        print(f"           - {title}")

    def close(self):
        """리소스 정리"""
        self.pdf.close()


def main():
    if len(sys.argv) < 2:
        print("사용법: python advanced_pdf_analyzer.py <PDF파일경로> [출력JSON경로]")
        sys.exit(1)

    pdf_path = sys.argv[1]
    output_path = sys.argv[2] if len(sys.argv) > 2 else pdf_path.replace('.pdf', '_analysis.json')

    analyzer = AdvancedPDFAnalyzer(pdf_path)

    try:
        # 전체 분석
        analyzer.analyze_all()

        # 요약 출력
        analyzer.print_summary()

        # JSON 저장
        analyzer.save_analysis(output_path)

    finally:
        analyzer.close()


if __name__ == '__main__':
    main()
