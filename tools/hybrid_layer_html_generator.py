"""
Hybrid Layer HTML Generator
배경: 100% 정확한 PNG 이미지
전경: 편집 가능한 투명 텍스트 레이어
"""

import sys
import json
import fitz  # PyMuPDF
from pathlib import Path
import base64


class HybridLayerHTMLGenerator:
    def __init__(self, pdf_path, json_path):
        self.pdf_path = Path(pdf_path)
        self.json_path = Path(json_path)
        self.doc = fitz.open(pdf_path)

        # JSON 데이터 로드
        with open(json_path, 'r', encoding='utf-8') as f:
            self.data = json.load(f)

        self.pages_data = []

    def pdf_page_to_base64_png(self, page_num, dpi=200):
        """PDF 페이지를 base64 PNG로 변환"""
        page = self.doc[page_num - 1]

        # 고해상도 렌더링
        mat = fitz.Matrix(dpi / 72, dpi / 72)
        pix = page.get_pixmap(matrix=mat, alpha=False)

        # PNG로 변환
        png_data = pix.tobytes("png")

        # base64 인코딩
        b64_data = base64.b64encode(png_data).decode('utf-8')

        return f"data:image/png;base64,{b64_data}"

    def extract_editable_texts(self, page_data):
        """페이지에서 편집 가능한 텍스트만 추출"""
        texts = []

        for text in page_data.get('texts', []):
            texts.append({
                'text': text['text'],
                'x': text['bbox']['x'],
                'y': text['bbox']['y'],
                'width': text['bbox']['width'],
                'height': text['bbox']['height'],
                'font_size': text['font']['size'],
                'font_name': text['font']['name'],
                'color': text['font']['color'],
                'bold': text['flags']['bold'],
                'italic': text['flags']['italic']
            })

        return texts

    def generate_page_html(self, page_num, page_data):
        """단일 페이지 HTML 생성"""
        print(f"페이지 {page_num} 처리 중...", end='\r')

        # 1. 배경 이미지 생성
        bg_image = self.pdf_page_to_base64_png(page_num)

        # 2. 텍스트 레이어 추출
        texts = self.extract_editable_texts(page_data)

        # 3. 페이지 크기
        width = page_data['dimensions']['width']
        height = page_data['dimensions']['height']

        self.pages_data.append({
            'page_num': page_num,
            'bg_image': bg_image,
            'texts': texts,
            'width': width,
            'height': height
        })

    def generate_full_html(self, output_path):
        """전체 HTML 문서 생성"""
        print(f"\n하이브리드 레이어 HTML 생성 시작")
        print(f"총 {len(self.data['pages'])}페이지")
        print("=" * 80)

        # 모든 페이지 처리
        for i, page_data in enumerate(self.data['pages'], 1):
            self.generate_page_html(i, page_data)

        print(f"\n페이지 렌더링 완료, HTML 생성 중...")

        # HTML 템플릿
        html = self._generate_html_template()

        # 파일 저장
        output_file = Path(output_path)
        output_file.write_text(html, encoding='utf-8')

        print(f"\n완료! 하이브리드 HTML 생성: {output_file}")
        print(f"파일 크기: {output_file.stat().st_size / 1024 / 1024:.2f} MB")
        print(f"\n브라우저에서 열기:")
        print(f"file:///{output_file.as_posix()}")

    def _generate_html_template(self):
        """HTML 템플릿 생성"""
        # 페이지별 HTML 생성
        pages_html = []

        for page in self.pages_data:
            # 텍스트 레이어 HTML
            texts_html = []
            for text in page['texts']:
                # 폰트 스타일
                font_weight = 'bold' if text['bold'] else 'normal'
                font_style = 'italic' if text['italic'] else 'normal'

                # 한글 폰트 매핑
                font_family = self._map_font(text['font_name'])

                texts_html.append(f'''
                <div class="editable-text"
                     contenteditable="true"
                     spellcheck="false"
                     style="
                         position: absolute;
                         left: {text['x']}px;
                         top: {text['y']}px;
                         width: {text['width']}px;
                         height: {text['height']}px;
                         font-size: {text['font_size']}px;
                         font-family: {font_family};
                         font-weight: {font_weight};
                         font-style: {font_style};
                         color: {text['color']};
                         background: transparent;
                         border: none;
                         outline: none;
                         white-space: pre-wrap;
                         overflow: visible;
                         line-height: 1.2;
                         padding: 0;
                         margin: 0;
                     "
                     data-original="{text['text']}">{text['text']}</div>
                ''')

            # 페이지 HTML
            page_html = f'''
            <div class="page" data-page="{page['page_num']}" style="
                width: {page['width']}px;
                height: {page['height']}px;
                position: relative;
                margin: 0 auto;
                background: white;
                box-shadow: 0 4px 20px rgba(0,0,0,0.15);
                overflow: hidden;
            ">
                <!-- 배경 레이어 (100% 정확) -->
                <img src="{page['bg_image']}"
                     alt="Page {page['page_num']}"
                     style="
                         position: absolute;
                         top: 0;
                         left: 0;
                         width: 100%;
                         height: 100%;
                         z-index: 1;
                         pointer-events: none;
                         user-select: none;
                     ">

                <!-- 편집 가능 텍스트 레이어 -->
                <div class="text-layer" style="
                    position: absolute;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 100%;
                    z-index: 2;
                ">
                    {''.join(texts_html)}
                </div>
            </div>
            '''

            pages_html.append(page_html)

        # 최종 HTML 문서
        return f'''<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>리멘 제안서 - 하이브리드 편집 버전</title>
    <style>
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}

        body {{
            background: #1a1a1a;
            font-family: 'Malgun Gothic', '맑은 고딕', sans-serif;
            overflow-x: hidden;
        }}

        /* 도구 모음 */
        .toolbar {{
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 1000;
            background: rgba(255, 255, 255, 0.95);
            padding: 15px 25px;
            border-radius: 30px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
            display: flex;
            align-items: center;
            gap: 15px;
        }}

        .toolbar button {{
            background: #0066cc;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            transition: all 0.3s;
        }}

        .toolbar button:hover {{
            background: #0052a3;
            transform: translateY(-2px);
        }}

        .toolbar button:disabled {{
            background: #ccc;
            cursor: not-allowed;
            transform: none;
        }}

        .page-indicator {{
            font-weight: bold;
            font-size: 16px;
            color: #333;
            min-width: 80px;
            text-align: center;
        }}

        .mode-toggle {{
            background: #28a745 !important;
        }}

        .mode-toggle.edit-mode {{
            background: #ffc107 !important;
        }}

        /* 슬라이드 컨테이너 */
        .slides-container {{
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 40px 20px;
            gap: 40px;
        }}

        .page {{
            display: block;
        }}

        /* 편집 모드 */
        .edit-mode .editable-text {{
            background: rgba(255, 255, 0, 0.1) !important;
            border: 1px dashed rgba(0, 102, 204, 0.3);
            cursor: text;
        }}

        .edit-mode .editable-text:hover {{
            background: rgba(255, 255, 0, 0.2) !important;
            border-color: rgba(0, 102, 204, 0.6);
        }}

        .edit-mode .editable-text:focus {{
            background: rgba(255, 255, 0, 0.3) !important;
            border-color: #0066cc;
            box-shadow: 0 0 0 2px rgba(0, 102, 204, 0.2);
        }}

        /* 읽기 모드 */
        .read-mode .editable-text {{
            cursor: default;
            pointer-events: none;
        }}

        /* 수정된 텍스트 표시 */
        .editable-text.modified {{
            background: rgba(255, 193, 7, 0.2) !important;
        }}

        /* 키보드 단축키 안내 */
        .keyboard-hint {{
            position: fixed;
            bottom: 20px;
            left: 20px;
            background: rgba(255, 255, 255, 0.9);
            padding: 12px 20px;
            border-radius: 8px;
            font-size: 12px;
            color: #666;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            z-index: 1000;
        }}

        /* 반응형 */
        @media (max-width: 1024px) {{
            .page {{
                transform: scale(0.8);
                transform-origin: top center;
            }}
        }}

        @media (max-width: 768px) {{
            .page {{
                transform: scale(0.6);
            }}
        }}
    </style>
</head>
<body class="read-mode">
    <!-- 도구 모음 -->
    <div class="toolbar">
        <button id="prev-btn">◀ 이전</button>
        <span id="page-indicator" class="page-indicator">1 / {len(self.pages_data)}</span>
        <button id="next-btn">다음 ▶</button>
        <button id="mode-toggle" class="mode-toggle">편집 모드</button>
        <button id="export-btn">변경사항 저장</button>
    </div>

    <!-- 키보드 단축키 안내 -->
    <div class="keyboard-hint">
        E: 편집/읽기 모드 전환 | Ctrl+S: 변경사항 저장 | ← →: 페이지 이동
    </div>

    <!-- 슬라이드 -->
    <div class="slides-container">
        {''.join(pages_html)}
    </div>

    <script>
        // 편집 모드 토글
        let isEditMode = false;
        const body = document.body;
        const modeToggleBtn = document.getElementById('mode-toggle');

        function toggleEditMode() {{
            isEditMode = !isEditMode;

            if (isEditMode) {{
                body.classList.remove('read-mode');
                body.classList.add('edit-mode');
                modeToggleBtn.textContent = '읽기 모드';
                modeToggleBtn.classList.add('edit-mode');
            }} else {{
                body.classList.remove('edit-mode');
                body.classList.add('read-mode');
                modeToggleBtn.textContent = '편집 모드';
                modeToggleBtn.classList.remove('edit-mode');
            }}
        }}

        modeToggleBtn.addEventListener('click', toggleEditMode);

        // 텍스트 수정 감지
        document.querySelectorAll('.editable-text').forEach(el => {{
            el.addEventListener('input', function() {{
                const original = this.getAttribute('data-original');
                if (this.textContent !== original) {{
                    this.classList.add('modified');
                }} else {{
                    this.classList.remove('modified');
                }}
            }});
        }});

        // 변경사항 저장
        document.getElementById('export-btn').addEventListener('click', function() {{
            const changes = [];

            document.querySelectorAll('.editable-text.modified').forEach(el => {{
                const page = el.closest('.page').dataset.page;
                const original = el.getAttribute('data-original');
                const modified = el.textContent;

                changes.push({{
                    page: parseInt(page),
                    original: original,
                    modified: modified,
                    position: {{
                        x: parseFloat(el.style.left),
                        y: parseFloat(el.style.top)
                    }}
                }});
            }});

            if (changes.length === 0) {{
                alert('변경된 내용이 없습니다.');
                return;
            }}

            // JSON으로 다운로드
            const dataStr = JSON.stringify(changes, null, 2);
            const blob = new Blob([dataStr], {{ type: 'application/json' }});
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = 'proposal_changes.json';
            a.click();

            alert(`${{changes.length}}개 변경사항이 저장되었습니다.`);
        }});

        // 키보드 단축키
        document.addEventListener('keydown', function(e) {{
            // E: 편집 모드 토글
            if (e.key === 'e' || e.key === 'E') {{
                if (!e.target.classList.contains('editable-text')) {{
                    toggleEditMode();
                }}
            }}

            // Ctrl+S: 저장
            if (e.ctrlKey && e.key === 's') {{
                e.preventDefault();
                document.getElementById('export-btn').click();
            }}
        }});

        // 페이지 네비게이션 (선택 사항)
        const pages = document.querySelectorAll('.page');
        let currentPage = 0;

        function scrollToPage(index) {{
            if (index >= 0 && index < pages.length) {{
                pages[index].scrollIntoView({{ behavior: 'smooth', block: 'center' }});
                currentPage = index;
                document.getElementById('page-indicator').textContent = `${{index + 1}} / ${{pages.length}}`;

                document.getElementById('prev-btn').disabled = index === 0;
                document.getElementById('next-btn').disabled = index === pages.length - 1;
            }}
        }}

        document.getElementById('prev-btn').addEventListener('click', () => scrollToPage(currentPage - 1));
        document.getElementById('next-btn').addEventListener('click', () => scrollToPage(currentPage + 1));

        // 초기화
        scrollToPage(0);

        // 키보드 네비게이션
        document.addEventListener('keydown', function(e) {{
            if (!e.target.classList.contains('editable-text')) {{
                if (e.key === 'ArrowLeft' || e.key === 'ArrowUp') {{
                    scrollToPage(currentPage - 1);
                }}
                if (e.key === 'ArrowRight' || e.key === 'ArrowDown') {{
                    scrollToPage(currentPage + 1);
                }}
            }}
        }});
    </script>
</body>
</html>'''

    def _map_font(self, pdf_font_name):
        """PDF 폰트를 웹 폰트로 매핑"""
        font_lower = pdf_font_name.lower()

        # 한글 폰트
        if 'nanum' in font_lower or 'gothic' in font_lower:
            return "'Nanum Gothic', 'Malgun Gothic', sans-serif"
        elif 'myeong' in font_lower or 'batang' in font_lower:
            return "'Nanum Myeongjo', serif"

        # 영문 폰트
        if 'arial' in font_lower:
            return "Arial, sans-serif"
        elif 'times' in font_lower:
            return "'Times New Roman', serif"
        elif 'courier' in font_lower:
            return "'Courier New', monospace"

        # 기본값
        return "'Malgun Gothic', '맑은 고딕', sans-serif"

    def close(self):
        """리소스 정리"""
        self.doc.close()


def main():
    if len(sys.argv) < 3:
        print("사용법: python hybrid_layer_html_generator.py <PDF경로> <JSON경로> [출력HTML경로]")
        print("예시: python hybrid_layer_html_generator.py proposal.pdf proposal_final.json output.html")
        sys.exit(1)

    pdf_path = sys.argv[1]
    json_path = sys.argv[2]
    output_path = sys.argv[3] if len(sys.argv) > 3 else 'proposal_hybrid.html'

    generator = HybridLayerHTMLGenerator(pdf_path, json_path)

    try:
        generator.generate_full_html(output_path)
    finally:
        generator.close()


if __name__ == '__main__':
    main()
