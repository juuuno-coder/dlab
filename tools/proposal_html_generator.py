"""
제안서 HTML 자동 생성 엔진
- JSON 분석 데이터 기반
- 페이지 타입별 템플릿 시스템
- 완전 자동화된 HTML 생성
"""

import json
import sys
from pathlib import Path
from html import escape

class ProposalHTMLGenerator:
    def __init__(self, analysis_json_path):
        """
        Args:
            analysis_json_path: PDF 분석 JSON 파일 경로
        """
        with open(analysis_json_path, 'r', encoding='utf-8') as f:
            self.analysis = json.load(f)

        self.pages_html = []

    def generate_cover_page(self, page_data):
        """표지 페이지 생성"""
        blocks = page_data['text_blocks']

        title = blocks[0]['text'] if len(blocks) > 0 else ''
        subtitle = blocks[1]['text'] if len(blocks) > 1 else ''
        date = blocks[2]['text'] if len(blocks) > 2 else ''
        company = blocks[3]['text'] if len(blocks) > 3 else ''

        return f'''
        <section class="slide" data-page="{page_data['page_number']}">
            <div class="slide-content cover-page">
                <h1 class="proposal-title">{escape(title)}</h1>
                <h2 class="proposal-subtitle">{escape(subtitle)}</h2>
                <div class="proposal-date">{escape(date)}</div>
                <div class="proposal-company">{escape(company)}</div>
            </div>
            <div class="page-number">{page_data['page_number']}</div>
        </section>
        '''

    def generate_toc_page(self, page_data):
        """목차 페이지 생성"""
        text = page_data['full_text']

        return f'''
        <section class="slide" data-page="{page_data['page_number']}">
            <div class="slide-content">
                <h1 class="main-title">2026년 제6회 부산 봄꽃 전시회 행사 대행 용역</h1>

                <div class="toc-grid">
                    <div class="toc-column">
                        <h3>Ⅰ. 제안개요</h3>
                        <ul>
                            <li>1. 제안목적</li>
                            <li>2. 제안범위</li>
                            <li>3. 제안특장점</li>
                            <li>4. 제안업체현황</li>
                        </ul>
                    </div>

                    <div class="toc-column">
                        <h3>Ⅱ. 추진계획</h3>
                        <ul>
                            <li>1. 사업총괄계획</li>
                            <li>2. 세부실행계획</li>
                            <li>3. 전체인력운영계획</li>
                            <li>4. 사업비집행내역</li>
                        </ul>
                    </div>

                    <div class="toc-column">
                        <h3>Ⅲ. 사업 관리</h3>
                        <ul>
                            <li>1. 추진일정</li>
                            <li>2. 관리계획</li>
                            <li>3. 참여인력이력사항</li>
                        </ul>
                    </div>

                    <div class="toc-column">
                        <h3>Ⅳ. 기타</h3>
                        <ul>
                            <li>1. 마케팅</li>
                            <li>2. 특별제안</li>
                            <li>3. 성과 및 사후관리</li>
                        </ul>
                    </div>
                </div>
            </div>
            <div class="page-number">{page_data['page_number']}</div>
        </section>
        '''

    def generate_divider_page(self, page_data):
        """구분 페이지 생성"""
        part = page_data.get('part') or ''
        blocks = page_data['text_blocks']

        # 섹션 리스트 추출
        sections = []
        for block in blocks[2:]:  # 처음 2개는 제목/Part
            text = block['text'].strip()
            if text and len(text) < 50:  # 짧은 텍스트만
                sections.append(text)

        sections_html = '\n'.join([f'<li>{escape(s)}</li>' for s in sections[:4]])

        return f'''
        <section class="slide" data-page="{page_data['page_number']}">
            <div class="slide-content divider-page">
                <h1 class="divider-title">2026년 제6회 부산 봄꽃 전시회<br>행사 대행 용역</h1>
                <h2 class="part-title">{escape(part)}</h2>
                <ul class="part-sections">
                    {sections_html}
                </ul>
            </div>
            <div class="page-number">{page_data['page_number']}</div>
        </section>
        '''

    def generate_content_table(self, page_data):
        """표가 있는 콘텐츠 페이지 생성"""
        part = page_data.get('part') or ''
        sections = page_data.get('section_titles', [])

        section_title = sections[0] if sections else ''

        # 표 데이터
        tables_html = ''
        for table in page_data['tables']:
            if not table['data']:
                continue

            rows_html = ''
            for i, row in enumerate(table['data']):
                if i == 0:  # 헤더
                    cells = ''.join([f'<th>{escape(str(cell))}</th>' for cell in row if cell])
                    rows_html += f'<tr>{cells}</tr>'
                else:  # 데이터
                    cells = ''.join([f'<td>{escape(str(cell))}</td>' for cell in row if cell])
                    if cells.strip():
                        rows_html += f'<tr>{cells}</tr>'

            tables_html += f'<table class="data-table">{rows_html}</table>'

        # 텍스트 내용 (표 제외)
        text_content = page_data['full_text'].split('\n')
        content_html = '<br>'.join([escape(line) for line in text_content[:10] if line.strip()])

        return f'''
        <section class="slide" data-page="{page_data['page_number']}">
            <div class="slide-content">
                <div class="part-header">{escape(part)}</div>
                <h2 class="section-title">{escape(section_title)}</h2>
                <div class="content">
                    {tables_html}
                </div>
            </div>
            <div class="page-number">{page_data['page_number']}</div>
        </section>
        '''

    def generate_content_generic(self, page_data):
        """일반 콘텐츠 페이지 생성"""
        part = page_data.get('part') or ''
        sections = page_data.get('section_titles', [])
        section_title = sections[0] if sections else ''

        # 텍스트 블록을 HTML로 변환
        content_html = ''
        for block in page_data['text_blocks'][:20]:  # 상위 20개
            text = block['text'].strip()
            if not text:
                continue

            # 크기에 따라 스타일 결정
            size = block['size']
            if size > 18:
                content_html += f'<h3>{escape(text)}</h3>'
            elif size > 14:
                content_html += f'<h4>{escape(text)}</h4>'
            elif text.startswith('-') or text.startswith('•'):
                content_html += f'<li>{escape(text[1:].strip())}</li>'
            else:
                content_html += f'<p>{escape(text)}</p>'

        return f'''
        <section class="slide" data-page="{page_data['page_number']}">
            <div class="slide-content">
                <div class="part-header">{escape(part)}</div>
                <h2 class="section-title">{escape(section_title)}</h2>
                <div class="content">
                    {content_html}
                </div>
            </div>
            <div class="page-number">{page_data['page_number']}</div>
        </section>
        '''

    def generate_page(self, page_data):
        """페이지 타입에 따라 적절한 HTML 생성"""
        page_type = page_data['page_type']

        if page_type == 'cover':
            return self.generate_cover_page(page_data)
        elif page_type == 'toc':
            return self.generate_toc_page(page_data)
        elif page_type == 'divider':
            return self.generate_divider_page(page_data)
        elif page_type == 'content_table':
            return self.generate_content_table(page_data)
        else:
            return self.generate_content_generic(page_data)

    def generate_all(self):
        """전체 페이지 HTML 생성"""
        print("HTML 생성 시작...")
        print("="*80)

        for page in self.analysis['pages']:
            page_num = page['page_number']
            print(f"생성 중: {page_num}/{self.analysis['metadata']['total_pages']}", end='\r')

            html = self.generate_page(page)
            self.pages_html.append(html)

        print(f"\nHTML 생성 완료! 총 {len(self.pages_html)}페이지")

        return self.pages_html

    def build_full_html(self, output_path):
        """완전한 HTML 파일 생성"""
        pages_content = '\n'.join(self.pages_html)

        html_template = f'''<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>2026년 제6회 부산 봄꽃 전시회 행사 대행 용역 제안서</title>
    <link rel="stylesheet" href="css/proposal.css">
    <link rel="stylesheet" href="css/theme.css">
    <style>
        /* 추가 스타일 */
        .data-table {{
            width: 100%;
            border-collapse: collapse;
            margin: 10mm 0;
        }}
        .data-table th,
        .data-table td {{
            border: 1px solid #ddd;
            padding: 2mm;
            text-align: left;
            font-size: 10pt;
        }}
        .data-table th {{
            background: #f0f0f0;
            font-weight: bold;
        }}
        .content p {{
            margin: 2mm 0;
            line-height: 1.6;
        }}
        .content h3 {{
            margin: 5mm 0 2mm 0;
            font-size: 14pt;
        }}
        .content h4 {{
            margin: 3mm 0 2mm 0;
            font-size: 12pt;
        }}
        .content li {{
            margin: 1mm 0;
            padding-left: 5mm;
        }}
    </style>
</head>
<body>
    <!-- 네비게이션 컨트롤 -->
    <div class="nav-controls">
        <button id="prev-btn" class="nav-btn">◀ 이전</button>
        <span id="page-indicator" class="page-indicator">1 / {self.analysis['metadata']['total_pages']}</span>
        <button id="next-btn" class="nav-btn">다음 ▶</button>
    </div>

    <!-- 슬라이드 컨테이너 -->
    <div class="slides-container" id="slides-container">
{pages_content}
    </div>

    <script src="js/proposal.js"></script>
</body>
</html>
'''

        # 파일 저장
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(html_template)

        print(f"\n완전한 HTML 파일 생성: {output_path}")

        return output_path


def main():
    if len(sys.argv) < 2:
        print("사용법: python proposal_html_generator.py <분석JSON경로> [출력HTML경로]")
        sys.exit(1)

    json_path = sys.argv[1]
    output_path = sys.argv[2] if len(sys.argv) > 2 else 'proposal_generated.html'

    generator = ProposalHTMLGenerator(json_path)
    generator.generate_all()
    generator.build_full_html(output_path)

    print("\n" + "="*80)
    print("생성 완료!")
    print(f"HTML 파일: {output_path}")
    print("="*80)


if __name__ == '__main__':
    main()
