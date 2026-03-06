"""
발표대본 마크다운을 제안서 HTML 슬라이드로 변환
Limen 제안서 디자인 시스템 적용
"""

import sys
import re
from pathlib import Path
from typing import List, Dict

class ProposalSlideGenerator:
    def __init__(self, md_path: str):
        self.md_path = Path(md_path)
        self.slides: List[Dict] = []
        self.content = self.md_path.read_text(encoding='utf-8')

    def parse_markdown(self):
        """마크다운을 슬라이드로 파싱"""
        # 섹션별로 분리 (## 또는 --- 기준)
        sections = re.split(r'\n---\n|\n## ', self.content)

        slide_num = 0

        for section in sections:
            if not section.strip():
                continue

            # 섹션 타이틀과 본문 분리
            lines = section.strip().split('\n')

            # 첫 줄이 타이틀인지 확인
            if lines[0].startswith('# '):
                # 커버 슬라이드
                title = lines[0].replace('# ', '').strip()
                subtitle_lines = []
                for line in lines[1:]:
                    if line.strip() and not line.startswith('발표일:'):
                        subtitle_lines.append(line.strip())

                slide_num += 1
                self.slides.append({
                    'type': 'cover',
                    'number': slide_num,
                    'title': title,
                    'subtitle': '\n'.join(subtitle_lines[:3]),
                })
            else:
                # 일반 콘텐츠 슬라이드
                # 첫 줄을 타이틀로
                title = lines[0].strip()

                # 시간 표시 제거 (예: (2분))
                title = re.sub(r'\s*\([0-9]+분\)', '', title)

                content_lines = []
                current_list = []

                for line in lines[1:]:
                    line = line.strip()

                    if not line:
                        continue

                    # ### 하위 섹션 타이틀
                    if line.startswith('###'):
                        if current_list:
                            content_lines.append({
                                'type': 'list',
                                'items': current_list
                            })
                            current_list = []

                        subtitle = line.replace('### ', '').strip()
                        subtitle = re.sub(r'\s*\([0-9]+분\)', '', subtitle)
                        content_lines.append({
                            'type': 'subtitle',
                            'text': subtitle
                        })
                    # 리스트 아이템
                    elif line.startswith('첫째,') or line.startswith('둘째,') or line.startswith('셋째,') or line.startswith('넷째,') or line.startswith('다섯째,') or line.startswith('여섯째,'):
                        current_list.append(line)
                    # 일반 텍스트
                    else:
                        if current_list:
                            content_lines.append({
                                'type': 'list',
                                'items': current_list
                            })
                            current_list = []

                        content_lines.append({
                            'type': 'text',
                            'text': line
                        })

                # 마지막 리스트 추가
                if current_list:
                    content_lines.append({
                        'type': 'list',
                        'items': current_list
                    })

                if content_lines:
                    slide_num += 1
                    self.slides.append({
                        'type': 'content',
                        'number': slide_num,
                        'title': title,
                        'content': content_lines
                    })

        return self.slides

    def generate_cover_slide(self, slide: Dict) -> str:
        """커버 슬라이드 HTML 생성"""
        return f'''
    <section class="slide slide-cover">
        <div class="slide-content">
            <h1 class="cover-title">{slide['title']}</h1>
            <p class="cover-subtitle">{slide['subtitle']}</p>
        </div>
        <div class="slide-footer">
            <span class="slide-number">{slide['number']}</span>
        </div>
    </section>
        '''

    def generate_content_slide(self, slide: Dict) -> str:
        """콘텐츠 슬라이드 HTML 생성"""
        content_html = []

        for item in slide['content']:
            if item['type'] == 'subtitle':
                content_html.append(f'<h3 class="content-subtitle">{item["text"]}</h3>')
            elif item['type'] == 'list':
                items_html = '\n'.join([f'<li>{text}</li>' for text in item['items']])
                content_html.append(f'<ul class="content-list">{items_html}</ul>')
            elif item['type'] == 'text':
                content_html.append(f'<p class="content-text">{item["text"]}</p>')

        return f'''
    <section class="slide slide-content">
        <div class="slide-content">
            <h2 class="content-title">{slide['title']}</h2>
            <div class="content-body">
                {''.join(content_html)}
            </div>
        </div>
        <div class="slide-footer">
            <span class="slide-number">{slide['number']}</span>
        </div>
    </section>
        '''

    def generate_html(self, output_path: str):
        """완전한 HTML 문서 생성"""
        self.parse_markdown()

        slides_html = []
        for slide in self.slides:
            if slide['type'] == 'cover':
                slides_html.append(self.generate_cover_slide(slide))
            else:
                slides_html.append(self.generate_content_slide(slide))

        html = f'''<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>2026 부산 봄꽃 전시회 제안서</title>
    <style>
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}

        body {{
            background: #1a1a1a;
            font-family: 'Malgun Gothic', '맑은 고딕', 'Noto Sans KR', sans-serif;
            overflow: hidden;
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

        .nav-btn:hover {{
            background: #0052a3;
            transform: translateY(-2px);
        }}

        .nav-btn:disabled {{
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

        /* 슬라이드 컨테이너 */
        .slides-container {{
            width: 100vw;
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }}

        .slide {{
            display: none;
            width: 1200px;
            height: 675px;
            background: white;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.5);
            position: relative;
        }}

        .slide.active {{
            display: flex;
            flex-direction: column;
        }}

        .slide-content {{
            flex: 1;
            padding: 60px 80px;
            overflow-y: auto;
        }}

        .slide-footer {{
            height: 60px;
            background: linear-gradient(135deg, #0066cc 0%, #0052a3 100%);
            display: flex;
            align-items: center;
            justify-content: flex-end;
            padding: 0 40px;
        }}

        .slide-number {{
            color: white;
            font-size: 18px;
            font-weight: 600;
        }}

        /* 커버 슬라이드 */
        .slide-cover .slide-content {{
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            text-align: center;
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
        }}

        .cover-title {{
            font-size: 48px;
            font-weight: 900;
            color: #0066cc;
            margin-bottom: 30px;
            line-height: 1.3;
        }}

        .cover-subtitle {{
            font-size: 20px;
            color: #555;
            line-height: 1.8;
            max-width: 800px;
            white-space: pre-line;
        }}

        /* 콘텐츠 슬라이드 */
        .content-title {{
            font-size: 36px;
            font-weight: 800;
            color: #0066cc;
            margin-bottom: 40px;
            border-bottom: 4px solid #0066cc;
            padding-bottom: 15px;
        }}

        .content-subtitle {{
            font-size: 28px;
            font-weight: 700;
            color: #333;
            margin: 30px 0 20px 0;
        }}

        .content-text {{
            font-size: 20px;
            color: #555;
            line-height: 1.8;
            margin-bottom: 20px;
        }}

        .content-list {{
            list-style: none;
            margin: 20px 0;
        }}

        .content-list li {{
            font-size: 20px;
            color: #555;
            line-height: 1.8;
            margin-bottom: 15px;
            padding-left: 30px;
            position: relative;
        }}

        .content-list li::before {{
            content: "▸";
            position: absolute;
            left: 0;
            color: #0066cc;
            font-size: 24px;
        }}

        /* 반응형 */
        @media (max-width: 1400px) {{
            .slide {{
                transform: scale(0.85);
            }}
        }}

        @media (max-width: 1024px) {{
            .slide {{
                transform: scale(0.7);
            }}
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
        }}

        @media (max-width: 768px) {{
            .keyboard-hint {{
                display: none;
            }}
        }}
    </style>
</head>
<body>
    <!-- 네비게이션 -->
    <div class="nav-controls">
        <button id="prev-btn" class="nav-btn">◀ 이전</button>
        <span id="page-indicator" class="page-indicator">1 / {len(self.slides)}</span>
        <button id="next-btn" class="nav-btn">다음 ▶</button>
    </div>

    <!-- 키보드 단축키 안내 -->
    <div class="keyboard-hint">
        ← → 키로 페이지 이동 | F 또는 F11: 전체화면
    </div>

    <!-- 슬라이드 -->
    <div class="slides-container">
{''.join(slides_html)}
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

        // 버튼 이벤트
        document.getElementById('prev-btn').addEventListener('click', () => showSlide(currentSlide - 1));
        document.getElementById('next-btn').addEventListener('click', () => showSlide(currentSlide + 1));

        // 키보드 네비게이션
        document.addEventListener('keydown', (e) => {{
            if (e.key === 'ArrowLeft' || e.key === 'PageUp') showSlide(currentSlide - 1);
            if (e.key === 'ArrowRight' || e.key === 'PageDown' || e.key === ' ') {{
                e.preventDefault();
                showSlide(currentSlide + 1);
            }}
            if (e.key === 'Home') showSlide(0);
            if (e.key === 'End') showSlide(slides.length - 1);
            if (e.key === 'f' || e.key === 'F11') {{
                e.preventDefault();
                if (!document.fullscreenElement) {{
                    document.documentElement.requestFullscreen();
                }} else {{
                    document.exitFullscreen();
                }}
            }}
        }});

        // 초기화
        showSlide(0);

        // 터치 스와이프 지원
        let touchStartX = 0;
        let touchEndX = 0;

        document.addEventListener('touchstart', e => {{
            touchStartX = e.changedTouches[0].screenX;
        }});

        document.addEventListener('touchend', e => {{
            touchEndX = e.changedTouches[0].screenX;
            if (touchEndX < touchStartX - 50) showSlide(currentSlide + 1);
            if (touchEndX > touchStartX + 50) showSlide(currentSlide - 1);
        }});
    </script>
</body>
</html>'''

        # 파일 저장
        output_file = Path(output_path)
        output_file.write_text(html, encoding='utf-8')

        print(f"\n[OK] 제안서 HTML 생성 완료!")
        print(f"파일: {output_file}")
        print(f"슬라이드 수: {len(self.slides)}개")
        print(f"\n브라우저에서 열기:")
        print(f"file:///{output_file.as_posix()}")


def main():
    if len(sys.argv) < 2:
        print("사용법: python md_to_proposal_slides.py <발표대본.md> [출력HTML경로]")
        print("예시: python md_to_proposal_slides.py 2026_부산봄꽃전시회_발표대본.md proposal_slides.html")
        sys.exit(1)

    md_path = sys.argv[1]
    output_path = sys.argv[2] if len(sys.argv) > 2 else 'proposal_slides.html'

    generator = ProposalSlideGenerator(md_path)
    generator.generate_html(output_path)


if __name__ == '__main__':
    main()
