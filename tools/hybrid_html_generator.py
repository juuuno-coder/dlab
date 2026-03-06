"""
하이브리드 HTML 생성기 (AI 최적화)
- 이미지 가이드 레이어
- SVG 도형 렌더링
- 웹 폰트 자동 매칭
- WYSIWYG 편집 툴바
"""

import json
import sys
import base64
from pathlib import Path
from html import escape
import fitz  # PyMuPDF

class HybridHTMLGenerator:
    def __init__(self, analysis_json_path, pdf_path=None):
        with open(analysis_json_path, 'r', encoding='utf-8') as f:
            self.analysis = json.load(f)

        self.pdf_path = pdf_path
        self.pages_html = []
        self.guide_images = []  # 가이드 이미지 저장

    def round_coord(self, value):
        """좌표 값을 반올림하여 정밀도 문제 해결"""
        if abs(value) < 0.001:
            return 0
        return round(value, 2)

    def generate_guide_images(self):
        """PDF를 가이드 이미지로 변환"""
        if not self.pdf_path or not Path(self.pdf_path).exists():
            print("PDF 파일이 없어 가이드 이미지를 생성하지 않습니다.")
            return

        print("가이드 이미지 생성 중...")
        doc = fitz.open(self.pdf_path)

        for page_num in range(len(doc)):
            page = doc[page_num]

            # 150 DPI로 렌더링 (가이드용이므로 고해상도 불필요)
            zoom = 150 / 72
            mat = fitz.Matrix(zoom, zoom)
            pix = page.get_pixmap(matrix=mat, alpha=False)

            # PNG 이미지로 변환
            img_bytes = pix.tobytes("png")
            img_base64 = base64.b64encode(img_bytes).decode('utf-8')
            img_data_url = f"data:image/png;base64,{img_base64}"

            self.guide_images.append(img_data_url)
            print(f"가이드 이미지 생성: {page_num + 1}/{len(doc)}", end='\r')

        doc.close()
        print(f"\n가이드 이미지 생성 완료: {len(self.guide_images)}개")

    def generate_svg_drawing(self, drawing, page_height):
        """도형을 SVG로 변환"""
        rect = drawing['rect']
        x, y, w, h = rect['x'], rect['y'], rect['width'], rect['height']

        # Y 좌표 변환
        y_html = self.round_coord(page_height - y - h)

        # SVG 요소 생성
        svg_content = ''

        if drawing['type'] == 'rect':
            # 사각형
            fill = drawing.get('fill_color', 'none')
            stroke = drawing.get('stroke_color', 'none')
            stroke_width = drawing.get('stroke_width', 1)

            svg_content = f'''<rect x="0" y="0" width="{self.round_coord(w)}" height="{self.round_coord(h)}"
                fill="{fill}" stroke="{stroke}" stroke-width="{stroke_width}"
                class="svg-rect editable-shape" data-fill="{fill}" data-stroke="{stroke}"/>'''

        elif drawing['type'] == 'circle':
            # 원
            cx = self.round_coord(w / 2)
            cy = self.round_coord(h / 2)
            r = min(cx, cy)
            fill = drawing.get('fill_color', 'none')
            stroke = drawing.get('stroke_color', 'none')

            svg_content = f'''<circle cx="{cx}" cy="{cy}" r="{r}"
                fill="{fill}" stroke="{stroke}"
                class="svg-circle editable-shape" data-fill="{fill}"/>'''

        elif drawing['type'] == 'line':
            # 선
            stroke = drawing.get('stroke_color', '#000000')
            stroke_width = max(1.5, drawing.get('stroke_width', 1.5))

            if h == 0 or h < 1:  # 수평선
                svg_content = f'''<line x1="0" y1="0" x2="{self.round_coord(w)}" y2="0"
                    stroke="{stroke}" stroke-width="{stroke_width}"
                    class="svg-line editable-shape" data-stroke="{stroke}"/>'''
            else:  # 수직선
                svg_content = f'''<line x1="0" y1="0" x2="0" y2="{self.round_coord(h)}"
                    stroke="{stroke}" stroke-width="{stroke_width}"
                    class="svg-line editable-shape" data-stroke="{stroke}"/>'''

        else:
            # 기타 도형은 기본 div로
            fill = drawing.get('fill_color', 'transparent')
            return f'<div style="position: absolute; left: {self.round_coord(x)}px; top: {y_html}px; width: {self.round_coord(w)}px; height: {self.round_coord(h)}px; background: {fill};"></div>'

        # SVG 컨테이너
        return f'''<svg style="position: absolute; left: {self.round_coord(x)}px; top: {y_html}px; width: {self.round_coord(w)}px; height: {self.round_coord(h)}px; overflow: visible;" class="drawing-svg">
            {svg_content}
        </svg>'''

    def get_web_font(self, pdf_font_name):
        """PDF 폰트를 웹 폰트로 스마트 매칭"""
        # 한글 폰트 우선 매칭
        korean_fonts = {
            'nanum': '"Nanum Gothic", "나눔고딕"',
            'malgun': '"Malgun Gothic", "맑은 고딕"',
            'batang': '"Batang", "바탕"',
            'dotum': '"Dotum", "돋움"',
            'gulim': '"Gulim", "굴림"',
            'gungsuh': '"Gungsuh", "궁서"',
        }

        # 영문 폰트 매칭
        english_fonts = {
            'arial': 'Arial, sans-serif',
            'helvetica': 'Helvetica, sans-serif',
            'times': '"Times New Roman", serif',
            'courier': '"Courier New", monospace',
            'verdana': 'Verdana, sans-serif',
        }

        pdf_font_lower = pdf_font_name.lower()

        # 한글 폰트 체크
        for key, font in korean_fonts.items():
            if key in pdf_font_lower:
                return font

        # 영문 폰트 체크
        for key, font in english_fonts.items():
            if key in pdf_font_lower:
                return font

        # 기본 폰트 스택
        return '"Malgun Gothic", "맑은 고딕", "Noto Sans KR", sans-serif'

    def generate_text_html(self, text_info, page_height):
        """텍스트를 HTML로 변환 (편집 가능 + 웹폰트)"""
        text = escape(text_info['text'])
        bbox = text_info['bbox']
        font = text_info['font']

        x, y, w, h = bbox['x'], bbox['y'], bbox['width'], bbox['height']
        y_html = self.round_coord(page_height - (y + h))

        # 웹 폰트 매칭
        font_family = self.get_web_font(font['name'])
        font_size = self.round_coord(font['size'])
        font_color = font['color']

        font_weight = 'bold' if text_info['flags']['bold'] else 'normal'
        font_style = 'italic' if text_info['flags']['italic'] else 'normal'

        return f'''<span class="text editable" contenteditable="true"
            data-font-size="{font_size}" data-color="{font_color}" data-weight="{font_weight}"
            style="position: absolute; left: {self.round_coord(x)}px; top: {y_html}px;
                   font-family: {font_family}; font-size: {font_size}px; color: {font_color};
                   font-weight: {font_weight}; font-style: {font_style};
                   white-space: pre-wrap; cursor: text; outline: none;
                   line-height: {self.round_coord(h)}px; min-height: {self.round_coord(h)}px;">{text}</span>'''

    def generate_image_html(self, image_info, page_height):
        """이미지를 HTML로 변환"""
        bbox = image_info['bbox']
        x, y, w, h = bbox['x'], bbox['y'], bbox['width'], bbox['height']
        y_html = self.round_coord(page_height - y - h)

        image_data = image_info.get('image_data')

        if image_data:
            return f'<img src="{image_data}" style="position: absolute; left: {self.round_coord(x)}px; top: {y_html}px; width: {self.round_coord(w)}px; height: {self.round_coord(h)}px; object-fit: contain;" alt="">'
        else:
            return f'<div style="position: absolute; left: {self.round_coord(x)}px; top: {y_html}px; width: {self.round_coord(w)}px; height: {self.round_coord(h)}px; background: #f0f0f0; border: 1px dashed #ccc;"></div>'

    def merge_nearby_texts(self, texts):
        """같은 줄의 텍스트들을 병합"""
        if not texts:
            return []

        sorted_texts = sorted(texts, key=lambda t: (t['bbox']['y'], t['bbox']['x']))
        merged = []
        current_group = [sorted_texts[0]]

        for i in range(1, len(sorted_texts)):
            current = sorted_texts[i]
            prev = current_group[-1]

            y_diff = abs(current['bbox']['y'] - prev['bbox']['y'])
            x_gap = current['bbox']['x'] - (prev['bbox']['x'] + prev['bbox']['width'])

            if y_diff < 5 and x_gap < 50:
                current_group.append(current)
            else:
                if len(current_group) > 1:
                    merged.append(self._merge_text_group(current_group))
                else:
                    merged.append(current_group[0])
                current_group = [current]

        if len(current_group) > 1:
            merged.append(self._merge_text_group(current_group))
        else:
            merged.append(current_group[0])

        return merged

    def _merge_text_group(self, group):
        """텍스트 그룹을 하나로 병합"""
        texts = [t['text'] for t in group]
        merged_text = ' '.join(texts)

        x0 = min([t['bbox']['x'] for t in group])
        y0 = min([t['bbox']['y'] for t in group])
        x1 = max([t['bbox']['x'] + t['bbox']['width'] for t in group])
        y1 = max([t['bbox']['y'] + t['bbox']['height'] for t in group])

        first = group[0]

        return {
            'text': merged_text,
            'bbox': {'x': x0, 'y': y0, 'width': x1 - x0, 'height': y1 - y0},
            'font': first['font'],
            'flags': first['flags']
        }

    def generate_page_html(self, page_data, page_index):
        """단일 페이지를 HTML로 변환 (하이브리드)"""
        page_num = page_data['page_number']
        dims = page_data['dimensions']
        width, height = dims['width'], dims['height']
        bg_color = page_data['background']['color']

        # 가이드 이미지 (있는 경우)
        guide_layer = ''
        if page_index < len(self.guide_images):
            guide_layer = f'''<img src="{self.guide_images[page_index]}"
                class="guide-layer"
                style="position: absolute; top: 0; left: 0; width: 100%; height: 100%;
                       opacity: 0.3; pointer-events: none; z-index: 0;"
                alt="Guide">'''

        # 텍스트 병합
        merged_texts = self.merge_nearby_texts(page_data['texts'])

        # HTML 생성
        html_parts = [
            f'<section class="slide" data-page="{page_num}">',
            f'  <div class="slide-content" style="position: relative; width: {self.round_coord(width)}px; height: {self.round_coord(height)}px; background-color: {bg_color}; margin: 0 auto; box-shadow: 0 5px 20px rgba(0,0,0,0.2);">',
            f'    {guide_layer}',  # 가이드 레이어
            f'    <div class="editable-layer" style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; z-index: 1;">',
        ]

        # 도형 (SVG)
        for drawing in page_data['drawings']:
            html_parts.append('      ' + self.generate_svg_drawing(drawing, height))

        # 이미지
        for image in page_data['images']:
            html_parts.append('      ' + self.generate_image_html(image, height))

        # 텍스트
        for text in merged_texts:
            html_parts.append('      ' + self.generate_text_html(text, height))

        html_parts.append('    </div>')  # editable-layer
        html_parts.append('  </div>')  # slide-content
        html_parts.append(f'  <div class="page-number">{page_num}</div>')
        html_parts.append('</section>')

        return '\n'.join(html_parts)

    def generate_all_pages(self):
        """전체 페이지 HTML 생성"""
        print("HTML 생성 시작...")
        print("="*80)

        # 가이드 이미지 생성 (PDF가 있는 경우)
        if self.pdf_path:
            self.generate_guide_images()

        total = self.analysis['metadata']['total_pages']

        for idx, page_data in enumerate(self.analysis['pages']):
            page_num = page_data['page_number']
            print(f"생성 중: {page_num}/{total}", end='\r')

            html = self.generate_page_html(page_data, idx)
            self.pages_html.append(html)

        print(f"\n생성 완료! 총 {len(self.pages_html)}페이지")
        return self.pages_html

    def build_complete_html(self, output_path):
        """완전한 HTML 문서 생성 (툴바 포함)"""
        pages_content = '\n\n'.join(self.pages_html)

        html = f'''<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>하이브리드 제안서 에디터 - AI 최적화</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Nanum+Gothic:wght@400;700;800&display=swap" rel="stylesheet">
    <style>
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}

        body {{
            background: #2b2b2b;
            font-family: 'Nanum Gothic', 'Malgun Gothic', '맑은 고딕', sans-serif;
            overflow-x: hidden;
        }}

        /* 편집 툴바 */
        .edit-toolbar {{
            position: fixed;
            top: 80px;
            right: 20px;
            z-index: 2000;
            background: rgba(255, 255, 255, 0.95);
            padding: 15px;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
            display: none;  /* 요소 선택 시 표시 */
        }}

        .edit-toolbar.active {{
            display: block;
        }}

        .toolbar-group {{
            margin-bottom: 10px;
        }}

        .toolbar-label {{
            font-size: 11px;
            color: #666;
            margin-bottom: 5px;
            font-weight: 600;
        }}

        .toolbar-btn {{
            background: #007bff;
            color: white;
            border: none;
            padding: 8px 12px;
            border-radius: 6px;
            cursor: pointer;
            font-size: 12px;
            margin-right: 5px;
            transition: all 0.2s;
        }}

        .toolbar-btn:hover {{
            background: #0056b3;
        }}

        .toolbar-input {{
            padding: 6px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 12px;
            width: 80px;
        }}

        /* 네비게이션 */
        .nav-controls {{
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 1000;
            display: flex;
            align-items: center;
            gap: 15px;
            background: rgba(255, 255, 255, 0.95);
            padding: 12px 24px;
            border-radius: 30px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
        }}

        .nav-btn {{
            background: #007bff;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            transition: all 0.3s;
        }}

        .nav-btn:hover {{
            background: #0056b3;
            transform: translateY(-2px);
        }}

        .nav-btn:disabled {{
            background: #ccc;
            cursor: not-allowed;
            transform: none;
        }}

        .guide-toggle {{
            background: #39FF14;
            color: #050505;
        }}

        .guide-toggle:hover {{
            background: #2dd60f;
        }}

        .page-indicator {{
            font-weight: bold;
            font-size: 16px;
            color: #333;
            min-width: 80px;
            text-align: center;
        }}

        /* 슬라이드 */
        .slides-container {{
            padding: 150px 20px 50px;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }}

        .slide {{
            display: none;
            width: 100%;
            max-width: 1000px;
            margin: 0 auto;
        }}

        .slide.active {{
            display: flex;
            justify-content: center;
            align-items: center;
            flex-direction: column;
        }}

        .slide-content {{
            transform-origin: center center;
        }}

        .page-number {{
            text-align: center;
            margin-top: 10px;
            color: #aaa;
            font-size: 14px;
        }}

        /* 가이드 레이어 */
        .guide-layer.hidden {{
            display: none !important;
        }}

        /* 편집 가능 요소 */
        .editable {{
            transition: background-color 0.2s, box-shadow 0.2s;
        }}

        .editable:hover {{
            background-color: rgba(57, 255, 20, 0.05);
            box-shadow: 0 0 0 1px rgba(57, 255, 20, 0.3);
            border-radius: 2px;
        }}

        .editable:focus, .editable.selected {{
            background-color: rgba(57, 255, 20, 0.1);
            box-shadow: 0 0 0 2px rgba(57, 255, 20, 0.5);
            border-radius: 2px;
            outline: none;
        }}

        /* SVG 도형 */
        .editable-shape:hover {{
            filter: brightness(1.1);
            cursor: pointer;
        }}

        /* 반응형 */
        @media (max-width: 1200px) {{
            .slide-content {{
                transform: scale(0.85);
            }}
        }}

        @media (max-width: 768px) {{
            .slide-content {{
                transform: scale(0.7);
            }}
            .edit-toolbar {{
                display: none !important;
            }}
        }}
    </style>
</head>
<body>
    <!-- 네비게이션 -->
    <div class="nav-controls">
        <button id="guide-toggle" class="nav-btn guide-toggle">G: 가이드 숨김</button>
        <button id="prev-btn" class="nav-btn">◀ 이전</button>
        <span id="page-indicator" class="page-indicator">1 / {self.analysis['metadata']['total_pages']}</span>
        <button id="next-btn" class="nav-btn">다음 ▶</button>
    </div>

    <!-- 편집 툴바 -->
    <div id="edit-toolbar" class="edit-toolbar">
        <div class="toolbar-group">
            <div class="toolbar-label">폰트 크기</div>
            <input type="number" id="font-size-input" class="toolbar-input" min="8" max="72" value="12">
            <button id="font-size-apply" class="toolbar-btn">적용</button>
        </div>
        <div class="toolbar-group">
            <div class="toolbar-label">색상</div>
            <input type="color" id="color-input" class="toolbar-input" style="width: 60px;">
            <button id="color-apply" class="toolbar-btn">적용</button>
        </div>
        <div class="toolbar-group">
            <div class="toolbar-label">스타일</div>
            <button id="bold-toggle" class="toolbar-btn">B</button>
            <button id="italic-toggle" class="toolbar-btn">I</button>
        </div>
    </div>

    <!-- 슬라이드 -->
    <div class="slides-container">
{pages_content}
    </div>

    <script>
        // 슬라이드 네비게이션
        const slides = document.querySelectorAll('.slide');
        let currentSlide = 0;
        let guideVisible = true;
        let selectedElement = null;

        function showSlide(n) {{
            slides.forEach(s => s.classList.remove('active'));

            if (n < 0) n = 0;
            if (n >= slides.length) n = slides.length - 1;

            slides[n].classList.add('active');
            currentSlide = n;

            document.getElementById('page-indicator').textContent = `${{n + 1}} / ${{slides.length}}`;
            document.getElementById('prev-btn').disabled = n === 0;
            document.getElementById('next-btn').disabled = n === slides.length - 1;
        }}

        // 가이드 토글
        function toggleGuide() {{
            guideVisible = !guideVisible;
            const guides = document.querySelectorAll('.guide-layer');
            const btn = document.getElementById('guide-toggle');

            guides.forEach(g => {{
                if (guideVisible) {{
                    g.classList.remove('hidden');
                    btn.textContent = 'G: 가이드 숨김';
                }} else {{
                    g.classList.add('hidden');
                    btn.textContent = 'G: 가이드 표시';
                }}
            }});
        }}

        // 요소 선택
        function selectElement(el) {{
            if (selectedElement) {{
                selectedElement.classList.remove('selected');
            }}

            selectedElement = el;
            el.classList.add('selected');

            // 툴바 표시 및 값 설정
            const toolbar = document.getElementById('edit-toolbar');
            toolbar.classList.add('active');

            if (el.classList.contains('editable')) {{
                const fontSize = el.dataset.fontSize || window.getComputedStyle(el).fontSize.replace('px', '');
                const color = el.dataset.color || window.getComputedStyle(el).color;

                document.getElementById('font-size-input').value = fontSize;
                // color는 rgb()형식이므로 hex로 변환 필요 (간단히 현재 값 사용)
            }}
        }}

        // 이벤트 리스너
        document.getElementById('prev-btn').addEventListener('click', () => showSlide(currentSlide - 1));
        document.getElementById('next-btn').addEventListener('click', () => showSlide(currentSlide + 1));
        document.getElementById('guide-toggle').addEventListener('click', toggleGuide);

        // 키보드 네비게이션
        document.addEventListener('keydown', (e) => {{
            if (e.key === 'ArrowLeft') showSlide(currentSlide - 1);
            if (e.key === 'ArrowRight') showSlide(currentSlide + 1);
            if (e.key === 'g' || e.key === 'G') toggleGuide();
        }});

        // 요소 클릭 시 선택
        document.addEventListener('click', (e) => {{
            if (e.target.classList.contains('editable')) {{
                selectElement(e.target);
            }}
        }});

        // 툴바 기능
        document.getElementById('font-size-apply').addEventListener('click', () => {{
            if (selectedElement && selectedElement.classList.contains('editable')) {{
                const size = document.getElementById('font-size-input').value;
                selectedElement.style.fontSize = size + 'px';
                selectedElement.dataset.fontSize = size;
            }}
        }});

        document.getElementById('color-apply').addEventListener('click', () => {{
            if (selectedElement && selectedElement.classList.contains('editable')) {{
                const color = document.getElementById('color-input').value;
                selectedElement.style.color = color;
                selectedElement.dataset.color = color;
            }}
        }});

        document.getElementById('bold-toggle').addEventListener('click', () => {{
            if (selectedElement && selectedElement.classList.contains('editable')) {{
                const current = selectedElement.style.fontWeight;
                selectedElement.style.fontWeight = current === 'bold' ? 'normal' : 'bold';
            }}
        }});

        document.getElementById('italic-toggle').addEventListener('click', () => {{
            if (selectedElement && selectedElement.classList.contains('editable')) {{
                const current = selectedElement.style.fontStyle;
                selectedElement.style.fontStyle = current === 'italic' ? 'normal' : 'italic';
            }}
        }});

        // 초기화
        showSlide(0);
    </script>
</body>
</html>'''

        # 파일 저장
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(html)

        print(f"\n하이브리드 HTML 파일 생성: {output_path}")
        return output_path


def main():
    if len(sys.argv) < 2:
        print("사용법: python hybrid_html_generator.py <분석JSON경로> [PDF경로] [출력HTML경로]")
        print("예시: python hybrid_html_generator.py analysis.json original.pdf output.html")
        sys.exit(1)

    json_path = sys.argv[1]
    pdf_path = sys.argv[2] if len(sys.argv) > 2 else None
    output_path = sys.argv[3] if len(sys.argv) > 3 else 'hybrid_proposal.html'

    generator = HybridHTMLGenerator(json_path, pdf_path)
    generator.generate_all_pages()
    generator.build_complete_html(output_path)

    print("\n" + "="*80)
    print("[OK] 하이브리드 HTML 생성 완료!")
    print(f"파일: {output_path}")
    print("\n기능:")
    print("- G 키: 가이드 이미지 토글")
    print("- 텍스트 클릭: 편집 툴바 표시")
    print("- SVG 도형: 벡터 렌더링")
    print("- 웹 폰트: 자동 매칭")
    print("="*80)


if __name__ == '__main__':
    main()
