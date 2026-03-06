"""
픽셀 퍼펙트 HTML/CSS 생성 엔진
완벽한 PDF 분석 데이터를 기반으로 디자인을 정확히 재현
"""

import json
import sys
from pathlib import Path
from html import escape

class PerfectHTMLGenerator:
    def __init__(self, analysis_json_path):
        with open(analysis_json_path, 'r', encoding='utf-8') as f:
            self.analysis = json.load(f)

        self.pages_html = []

    def round_coord(self, value):
        """좌표 값을 반올림하여 정밀도 문제 해결"""
        if abs(value) < 0.001:  # 과학 표기법 방지
            return 0
        return round(value, 2)  # 소수점 2자리

    def generate_drawing_html(self, drawing, page_height):
        """도형을 HTML로 변환"""
        rect = drawing['rect']
        x, y, w, h = rect['x'], rect['y'], rect['width'], rect['height']

        # Y 좌표 그대로 사용 (PyMuPDF bbox가 이미 상단 기준일 수 있음)
        y_html = self.round_coord(y)

        # 스타일 (좌표 반올림 적용 + z-index)
        styles = [
            f"position: absolute",
            f"left: {self.round_coord(x)}px",
            f"top: {y_html}px",
            f"width: {self.round_coord(w)}px" if w > 0 else "width: 0",
            f"height: {self.round_coord(h)}px" if h > 0 else "height: 0",
            f"z-index: 1",  # 도형은 가장 아래
        ]

        # 채우기 색상
        if drawing['fill_color']:
            styles.append(f"background-color: {drawing['fill_color']}")

        # 테두리
        if drawing['stroke_color']:
            stroke_width = drawing.get('stroke_width', 1)
            styles.append(f"border: {stroke_width}px solid {drawing['stroke_color']}")

        # 선인 경우 (개선: border 대신 background-color 사용)
        if drawing['type'] == 'line':
            if h == 0 or h < 1:  # 수평선
                # 두께를 명확히 설정
                line_width = max(1.5, drawing.get('stroke_width', 1.5))
                styles = [
                    f"position: absolute",
                    f"left: {self.round_coord(x)}px",
                    f"top: {y_html}px",
                    f"width: {self.round_coord(w)}px",
                    f"height: {line_width}px",
                    f"background-color: {drawing['stroke_color']}",
                    f"border: none",
                ]
            elif w == 0 or w < 1:  # 수직선
                line_width = max(1.5, drawing.get('stroke_width', 1.5))
                styles = [
                    f"position: absolute",
                    f"left: {self.round_coord(x)}px",
                    f"top: {y_html}px",
                    f"width: {line_width}px",
                    f"height: {self.round_coord(h)}px",
                    f"background-color: {drawing['stroke_color']}",
                    f"border: none",
                ]

        style_str = '; '.join(styles)

        # 편집 가능한 속성 추가 (클릭 시 색상 변경 가능)
        data_attrs = []
        if drawing['fill_color']:
            data_attrs.append(f'data-fill="{drawing["fill_color"]}"')
        if drawing['stroke_color']:
            data_attrs.append(f'data-stroke="{drawing["stroke_color"]}"')

        data_str = ' '.join(data_attrs)
        return f'<div class="drawing editable-shape" {data_str} style="{style_str}" title="더블클릭으로 색상 변경"></div>'

    def generate_text_html(self, text_info, page_height):
        """텍스트를 HTML로 변환 (편집 가능)"""
        text = escape(text_info['text'])
        bbox = text_info['bbox']
        font = text_info['font']

        x, y, w, h = bbox['x'], bbox['y'], bbox['width'], bbox['height']

        # Y 좌표 그대로 사용 (테스트)
        y_html = self.round_coord(y)

        # 폰트 스타일
        font_family = self._get_font_family(font['name'])
        font_size = self.round_coord(font['size'])
        font_color = font['color']

        # 볼드/이탤릭
        font_weight = 'bold' if text_info['flags']['bold'] else 'normal'
        font_style = 'italic' if text_info['flags']['italic'] else 'normal'

        styles = [
            f"position: absolute",
            f"left: {self.round_coord(x)}px",
            f"top: {y_html}px",
            f"font-family: {font_family}",
            f"font-size: {font_size}px",
            f"color: {font_color}",
            f"font-weight: {font_weight}",
            f"font-style: {font_style}",
            f"white-space: pre-wrap",  # nowrap → pre-wrap (줄바꿈 허용)
            f"line-height: {self.round_coord(h)}px",
            f"min-height: {self.round_coord(h)}px",
            f"cursor: text",  # 편집 가능 커서
            f"outline: none",  # 포커스 시 외곽선 제거
            f"z-index: 3",  # 텍스트는 가장 위
        ]

        style_str = '; '.join(styles)
        return f'<span class="text editable" contenteditable="true" style="{style_str}">{text}</span>'

    def _get_font_family(self, pdf_font_name):
        """PDF 폰트명을 웹 폰트로 매핑 (간소화 버전)"""
        # 모든 폰트를 CSS 클래스로 처리하므로 간단히 반환
        # 실제 폰트 스택은 CSS의 .text 클래스에서 전역 관리
        font_map = {
            'Batang': 'serif',
            'Batang': 'serif',
            'Courier': 'monospace',
            'TimesNewRoman': 'serif',
        }

        # 세리프/모노스페이스 폰트만 구분
        for key, value in font_map.items():
            if key.lower() in pdf_font_name.lower():
                return value

        # 기본 고딕체 (CSS 전역 스택 사용)
        return 'inherit'

    def generate_image_html(self, image_info, page_height):
        """이미지를 HTML로 변환"""
        bbox = image_info['bbox']
        x, y, w, h = bbox['x'], bbox['y'], bbox['width'], bbox['height']

        # Y 좌표 그대로 사용
        y_html = self.round_coord(y)

        # 이미지 데이터 확인
        image_data = image_info.get('image_data')

        if image_data:
            # 실제 이미지가 있으면 img 태그로
            styles = [
                f"position: absolute",
                f"left: {self.round_coord(x)}px",
                f"top: {y_html}px",
                f"width: {self.round_coord(w)}px",
                f"height: {self.round_coord(h)}px",
                f"object-fit: contain",
                f"z-index: 2",  # 이미지는 도형 위, 텍스트 아래
            ]
            style_str = '; '.join(styles)
            return f'<img src="{image_data}" style="{style_str}" alt="">'
        else:
            # 이미지 데이터가 없으면 placeholder
            styles = [
                f"position: absolute",
                f"left: {self.round_coord(x)}px",
                f"top: {y_html}px",
                f"width: {self.round_coord(w)}px",
                f"height: {self.round_coord(h)}px",
                f"background: #f0f0f0",
                f"border: 1px dashed #ccc",
                f"z-index: 2",
            ]
            style_str = '; '.join(styles)
            return f'<div class="image-placeholder" style="{style_str}"></div>'

    def merge_nearby_texts(self, texts):
        """같은 줄의 텍스트들을 병합"""
        if not texts:
            return []

        # y 좌표 기준으로 정렬
        sorted_texts = sorted(texts, key=lambda t: (t['bbox']['y'], t['bbox']['x']))

        merged = []
        current_group = [sorted_texts[0]]

        for i in range(1, len(sorted_texts)):
            current = sorted_texts[i]
            prev = current_group[-1]

            # y 좌표 차이가 5px 미만이면 같은 줄로 간주
            y_diff = abs(current['bbox']['y'] - prev['bbox']['y'])
            x_gap = current['bbox']['x'] - (prev['bbox']['x'] + prev['bbox']['width'])

            if y_diff < 5 and x_gap < 50:  # 같은 줄이고 가까이 있으면
                current_group.append(current)
            else:
                # 그룹 병합
                if len(current_group) > 1:
                    merged_text = self._merge_text_group(current_group)
                    merged.append(merged_text)
                else:
                    merged.append(current_group[0])

                # 새 그룹 시작
                current_group = [current]

        # 마지막 그룹 처리
        if len(current_group) > 1:
            merged_text = self._merge_text_group(current_group)
            merged.append(merged_text)
        else:
            merged.append(current_group[0])

        return merged

    def _merge_text_group(self, group):
        """텍스트 그룹을 하나로 병합"""
        texts = [t['text'] for t in group]
        merged_text = ' '.join(texts)

        # 병합된 bbox
        x0 = min([t['bbox']['x'] for t in group])
        y0 = min([t['bbox']['y'] for t in group])
        x1 = max([t['bbox']['x'] + t['bbox']['width'] for t in group])
        y1 = max([t['bbox']['y'] + t['bbox']['height'] for t in group])

        # 첫 번째 요소의 폰트 정보 사용
        first = group[0]

        return {
            'text': merged_text,
            'bbox': {
                'x': x0,
                'y': y0,
                'width': x1 - x0,
                'height': y1 - y0
            },
            'font': first['font'],
            'flags': first['flags']
        }

    def generate_page_html(self, page_data):
        """단일 페이지를 HTML로 변환"""
        page_num = page_data['page_number']
        dims = page_data['dimensions']
        width, height = dims['width'], dims['height']

        # 배경
        bg_color = page_data['background']['color']

        # 페이지 컨테이너 스타일 (반올림 적용)
        page_styles = [
            f"position: relative",
            f"width: {self.round_coord(width)}px",
            f"height: {self.round_coord(height)}px",
            f"background-color: {bg_color}",
            f"margin: 0 auto",
            f"box-shadow: 0 5px 20px rgba(0,0,0,0.2)",
        ]

        page_style_str = '; '.join(page_styles)

        # 텍스트 병합 (같은 줄의 텍스트들을 하나로)
        merged_texts = self.merge_nearby_texts(page_data['texts'])

        # HTML 생성
        html_parts = [
            f'<section class="slide" data-page="{page_num}">',
            f'  <div class="slide-content" style="{page_style_str}">',
        ]

        # 도형 추가 (먼저 그려서 배경에 깔림)
        for drawing in page_data['drawings']:
            html_parts.append('    ' + self.generate_drawing_html(drawing, height))

        # 이미지 추가
        for image in page_data['images']:
            html_parts.append('    ' + self.generate_image_html(image, height))

        # 텍스트 추가 (병합된 버전, 마지막에 그려서 위에 표시)
        for text in merged_texts:
            html_parts.append('    ' + self.generate_text_html(text, height))

        html_parts.append('  </div>')
        html_parts.append(f'  <div class="page-number">{page_num}</div>')
        html_parts.append('</section>')

        return '\n'.join(html_parts)

    def generate_all_pages(self):
        """전체 페이지 HTML 생성"""
        print("HTML 생성 시작...")
        print("="*80)

        total = self.analysis['metadata']['total_pages']

        for page_data in self.analysis['pages']:
            page_num = page_data['page_number']
            print(f"생성 중: {page_num}/{total}", end='\r')

            html = self.generate_page_html(page_data)
            self.pages_html.append(html)

        print(f"\n생성 완료! 총 {len(self.pages_html)}페이지")

        return self.pages_html

    def build_complete_html(self, output_path):
        """완전한 HTML 문서 생성"""
        pages_content = '\n\n'.join(self.pages_html)

        html_template = f'''<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{self.analysis['metadata']['file_name']}</title>
    <style>
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}

        body {{
            background: #f5f5f5;
            font-family: 'Segoe UI', 'Malgun Gothic', '맑은 고딕', -apple-system, BlinkMacSystemFont, 'Apple SD Gothic Neo', 'Noto Sans KR', sans-serif;
            overflow-x: hidden;
        }}

        /* 전역 폰트 스택 */
        .text {{
            font-family: inherit;  /* body의 폰트 상속 */
        }}

        /* 편집 가능한 텍스트 */
        .editable {{
            transition: background-color 0.2s, box-shadow 0.2s;
        }}

        .editable:hover {{
            background-color: rgba(57, 255, 20, 0.05);  /* 네온 그린 살짝 */
            box-shadow: 0 0 0 1px rgba(57, 255, 20, 0.3);
            border-radius: 2px;
        }}

        .editable:focus {{
            background-color: rgba(57, 255, 20, 0.1);
            box-shadow: 0 0 0 2px rgba(57, 255, 20, 0.5);
            border-radius: 2px;
            outline: none;
        }}

        /* 네비게이션 컨트롤 */
        .nav-controls {{
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 1000;
            display: flex;
            align-items: center;
            gap: 15px;
            background: rgba(255, 255, 255, 0.95);
            padding: 10px 20px;
            border-radius: 25px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }}

        .nav-btn {{
            background: #007bff;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 14px;
        }}

        .nav-btn:hover {{
            background: #0056b3;
        }}

        .nav-btn:disabled {{
            background: #ccc;
            cursor: not-allowed;
        }}

        .page-indicator {{
            font-weight: bold;
            font-size: 14px;
        }}

        /* 슬라이드 컨테이너 (반응형 개선) */
        .slides-container {{
            padding: 50px 20px;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }}

        .slide {{
            display: none;
            width: 100%;
            max-width: 900px;
            margin: 0 auto;
        }}

        .slide.active {{
            display: flex;
            justify-content: center;
            align-items: center;
        }}

        /* 반응형 스케일링 */
        .slide-content {{
            /* 페이지별 스타일은 인라인으로 */
            transform-origin: center center;
        }}

        /* 모바일/태블릿 대응 */
        @media (max-width: 900px) {{
            .slide-content {{
                transform: scale(0.85);
            }}
            .slides-container {{
                padding: 20px 10px;
            }}
        }}

        @media (max-width: 768px) {{
            .slide-content {{
                transform: scale(0.7);
            }}
        }}

        @media (max-width: 480px) {{
            .slide-content {{
                transform: scale(0.5);
            }}
            .nav-controls {{
                top: 10px;
                right: 10px;
                padding: 6px 12px;
                font-size: 12px;
            }}
            .nav-btn {{
                padding: 6px 10px;
                font-size: 12px;
            }}
        }}

        .page-number {{
            text-align: center;
            margin-top: 10px;
            color: #666;
            font-size: 14px;
        }}

        /* 요소 스타일 */
        .drawing {{
            /* 개별 스타일은 인라인으로 */
        }}

        .text {{
            /* 개별 스타일은 인라인으로 */
        }}

        .image-placeholder {{
            /* 개별 스타일은 인라인으로 */
        }}

        /* 주석 마커 */
        .annotation-marker {{
            position: absolute;
            width: 24px;
            height: 24px;
            background: #39FF14;
            color: #000;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            font-weight: bold;
            cursor: pointer;
            z-index: 100;
            box-shadow: 0 2px 8px rgba(57, 255, 20, 0.5);
            transition: all 0.2s;
        }}

        .annotation-marker:hover {{
            transform: scale(1.2);
            box-shadow: 0 4px 12px rgba(57, 255, 20, 0.7);
        }}

        .annotation-tooltip {{
            position: absolute;
            background: rgba(0, 0, 0, 0.9);
            color: #39FF14;
            padding: 8px 12px;
            border-radius: 6px;
            font-size: 12px;
            max-width: 200px;
            z-index: 101;
            display: none;
            white-space: pre-wrap;
        }}

        .annotation-marker:hover .annotation-tooltip {{
            display: block;
        }}
    </style>
</head>
<body>
    <!-- 네비게이션 컨트롤 -->
    <div class="nav-controls">
        <button id="prev-btn" class="nav-btn">◀ 이전</button>
        <span id="page-indicator" class="page-indicator">1 / {self.analysis['metadata']['total_pages']}</span>
        <button id="next-btn" class="nav-btn">다음 ▶</button>
        <span style="margin: 0 10px; color: #ccc;">|</span>
        <button id="zoom-out" class="nav-btn">-</button>
        <span id="zoom-level" class="page-indicator" style="min-width: 60px;">100%</span>
        <button id="zoom-in" class="nav-btn">+</button>
        <button id="zoom-reset" class="nav-btn" style="margin-left: 5px;">초기화</button>
    </div>

    <!-- 슬라이드 컨테이너 -->
    <div class="slides-container" id="slides-container">
{pages_content}
    </div>

    <script>
        // 슬라이드 네비게이션
        const slides = document.querySelectorAll('.slide');
        let currentSlide = 0;

        function showSlide(n) {{
            slides.forEach(s => s.classList.remove('active'));

            if (n < 0) n = 0;
            if (n >= slides.length) n = slides.length - 1;

            slides[n].classList.add('active');
            currentSlide = n;

            // UI 업데이트
            document.getElementById('page-indicator').textContent = `${{n + 1}} / ${{slides.length}}`;
            document.getElementById('prev-btn').disabled = n === 0;
            document.getElementById('next-btn').disabled = n === slides.length - 1;
        }}

        // 이벤트 리스너
        document.getElementById('prev-btn').addEventListener('click', () => showSlide(currentSlide - 1));
        document.getElementById('next-btn').addEventListener('click', () => showSlide(currentSlide + 1));

        // 키보드 네비게이션
        document.addEventListener('keydown', (e) => {{
            if (e.key === 'ArrowLeft') showSlide(currentSlide - 1);
            if (e.key === 'ArrowRight') showSlide(currentSlide + 1);
        }});

        // 초기 슬라이드 표시
        showSlide(0);

        // 도형 색상 편집 기능
        document.addEventListener('dblclick', (e) => {{
            if (e.target.classList.contains('editable-shape')) {{
                const currentColor = e.target.dataset.fill || e.target.dataset.stroke || '#000000';
                const newColor = prompt('새 색상 입력 (예: #FF0000):', currentColor);

                if (newColor && /^#[0-9A-Fa-f]{{6}}$/.test(newColor)) {{
                    if (e.target.dataset.fill) {{
                        e.target.style.backgroundColor = newColor;
                        e.target.dataset.fill = newColor;
                    }}
                    if (e.target.dataset.stroke) {{
                        e.target.style.borderColor = newColor;
                        e.target.dataset.stroke = newColor;
                    }}
                }} else if (newColor) {{
                    alert('유효하지 않은 색상 코드입니다. #RRGGBB 형식으로 입력하세요.');
                }}
            }}
        }});

        // 텍스트 편집 시 자동 저장 (로컬스토리지)
        let editTimeout;
        document.querySelectorAll('.editable').forEach(el => {{
            el.addEventListener('input', () => {{
                clearTimeout(editTimeout);
                editTimeout = setTimeout(() => {{
                    console.log('변경된 텍스트:', el.textContent);
                    // 여기에 자동 저장 로직 추가 가능
                }}, 1000);
            }});
        }});

        // 줌 컨트롤
        let zoomLevel = 1.0;
        const container = document.getElementById('slides-container');
        const zoomLevelDisplay = document.getElementById('zoom-level');

        function updateZoom() {{
            const activeSlide = document.querySelector('.slide.active .slide-content');
            if (activeSlide) {{
                activeSlide.style.transform = `scale(${{zoomLevel}})`;
                activeSlide.style.transformOrigin = 'center center';
            }}
            zoomLevelDisplay.textContent = Math.round(zoomLevel * 100) + '%';
        }}

        document.getElementById('zoom-in').addEventListener('click', () => {{
            zoomLevel = Math.min(zoomLevel + 0.1, 3.0);  // 최대 300%
            updateZoom();
        }});

        document.getElementById('zoom-out').addEventListener('click', () => {{
            zoomLevel = Math.max(zoomLevel - 0.1, 0.3);  // 최소 30%
            updateZoom();
        }});

        document.getElementById('zoom-reset').addEventListener('click', () => {{
            zoomLevel = 1.0;
            updateZoom();
        }});

        // 슬라이드 변경 시 줌 유지
        const originalShowSlide = showSlide;
        showSlide = function(n) {{
            originalShowSlide(n);
            setTimeout(updateZoom, 10);  // 슬라이드 렌더링 후 줌 적용
        }};

        // 주석 기능 (Shift + 클릭으로 마커 추가)
        let annotations = JSON.parse(localStorage.getItem('proposal_annotations') || '{{}}');
        let annotationCounter = Object.keys(annotations).length;

        function saveAnnotations() {{
            localStorage.setItem('proposal_annotations', JSON.stringify(annotations));
        }}

        function loadAnnotations() {{
            const activeSlide = document.querySelector('.slide.active');
            if (!activeSlide) return;

            const pageNum = activeSlide.dataset.page;
            const slideContent = activeSlide.querySelector('.slide-content');

            // 기존 마커 제거
            slideContent.querySelectorAll('.annotation-marker').forEach(m => m.remove());

            // 현재 페이지 마커 표시
            Object.entries(annotations).forEach(([id, data]) => {{
                if (data.page == pageNum) {{
                    const marker = document.createElement('div');
                    marker.className = 'annotation-marker';
                    marker.innerHTML = `${{data.number}}<div class="annotation-tooltip">${{data.note}}</div>`;
                    marker.style.left = data.x + 'px';
                    marker.style.top = data.y + 'px';

                    // 마커 더블클릭 시 메모 수정
                    marker.addEventListener('dblclick', (e) => {{
                        e.stopPropagation();
                        const newNote = prompt('메모 수정:', data.note);
                        if (newNote !== null) {{
                            annotations[id].note = newNote;
                            saveAnnotations();
                            loadAnnotations();
                        }}
                    }});

                    // 마커 우클릭 시 삭제
                    marker.addEventListener('contextmenu', (e) => {{
                        e.preventDefault();
                        if (confirm('이 주석을 삭제하시겠습니까?')) {{
                            delete annotations[id];
                            saveAnnotations();
                            loadAnnotations();
                        }}
                    }});

                    slideContent.appendChild(marker);
                }}
            }});
        }}

        // 슬라이드 클릭 이벤트 (Shift + 클릭)
        document.addEventListener('click', (e) => {{
            if (!e.shiftKey) return;

            const slideContent = e.target.closest('.slide-content');
            if (!slideContent) return;

            const activeSlide = document.querySelector('.slide.active');
            if (!activeSlide) return;

            const rect = slideContent.getBoundingClientRect();
            const x = e.clientX - rect.left;
            const y = e.clientY - rect.top;

            const note = prompt('주석 메모:');
            if (!note) return;

            annotationCounter++;
            const id = 'ann_' + Date.now();
            annotations[id] = {{
                page: activeSlide.dataset.page,
                number: annotationCounter,
                x: x,
                y: y,
                note: note
            }};

            saveAnnotations();
            loadAnnotations();
        }});

        // 슬라이드 변경 시 주석 로드
        const originalShowSlide2 = showSlide;
        showSlide = function(n) {{
            originalShowSlide2(n);
            setTimeout(() => {{
                updateZoom();
                loadAnnotations();
            }}, 10);
        }};

        // 초기 로드
        setTimeout(loadAnnotations, 100);
    </script>
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
        print("사용법: python perfect_html_generator.py <분석JSON경로> [출력HTML경로]")
        sys.exit(1)

    json_path = sys.argv[1]
    output_path = sys.argv[2] if len(sys.argv) > 2 else 'proposal_perfect.html'

    generator = PerfectHTMLGenerator(json_path)
    generator.generate_all_pages()
    generator.build_complete_html(output_path)

    print("\n" + "="*80)
    print("[OK] 픽셀 퍼펙트 HTML 생성 완료!")
    print(f"파일: {output_path}")
    print("="*80)


if __name__ == '__main__':
    main()
