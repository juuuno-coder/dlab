"""
PDF를 페이지별 이미지로 변환하여 HTML 생성
PyMuPDF 사용 (poppler 불필요)
"""

import sys
import json
import base64
from pathlib import Path
import fitz  # PyMuPDF

def pdf_to_image_html(pdf_path, output_html, dpi=150):
    """
    PDF 각 페이지를 이미지로 변환하여 HTML 생성

    Args:
        pdf_path: PDF 파일 경로
        output_html: 출력 HTML 경로
        dpi: 해상도 (기본 150, 고품질 300)
    """
    print(f"PDF → 이미지 HTML 변환 시작: {pdf_path}")
    print(f"해상도: {dpi} DPI")
    print("="*80)

    doc = fitz.open(pdf_path)
    total_pages = len(doc)

    # 각 페이지를 이미지로 변환
    pages_html = []

    for page_num in range(total_pages):
        print(f"변환 중: {page_num + 1}/{total_pages}", end='\r')

        page = doc[page_num]

        # 해상도 설정 (DPI → zoom factor)
        zoom = dpi / 72  # 72 DPI가 기본
        mat = fitz.Matrix(zoom, zoom)

        # 페이지를 이미지로 렌더링
        pix = page.get_pixmap(matrix=mat, alpha=False)

        # PNG 이미지로 변환
        img_bytes = pix.tobytes("png")

        # base64 인코딩
        img_base64 = base64.b64encode(img_bytes).decode('utf-8')
        img_data_url = f"data:image/png;base64,{img_base64}"

        # HTML 슬라이드 생성
        page_html = f'''
        <section class="slide" data-page="{page_num + 1}">
            <img src="{img_data_url}"
                 alt="페이지 {page_num + 1}"
                 class="page-image">
            <div class="page-number">{page_num + 1}</div>
        </section>
        '''

        pages_html.append(page_html)

    print(f"\n변환 완료! 총 {total_pages}페이지")

    # 완전한 HTML 생성
    html_template = f'''<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>제안서 - {Path(pdf_path).stem}</title>
    <style>
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}

        body {{
            background: #2b2b2b;
            font-family: 'Segoe UI', 'Malgun Gothic', sans-serif;
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
            box-shadow: 0 4px 12px rgba(0, 123, 255, 0.4);
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
            overflow: hidden;
        }}

        .slide {{
            display: none;
            width: 100%;
            height: 100%;
            position: relative;
            justify-content: center;
            align-items: center;
        }}

        .slide.active {{
            display: flex;
        }}

        .page-image {{
            max-width: 95%;
            max-height: 95%;
            object-fit: contain;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.5);
            border-radius: 4px;
        }}

        .page-number {{
            position: absolute;
            bottom: 20px;
            left: 50%;
            transform: translateX(-50%);
            background: rgba(0, 0, 0, 0.7);
            color: white;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: 600;
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

        /* 반응형 */
        @media (max-width: 768px) {{
            .nav-controls {{
                top: 10px;
                right: 10px;
                padding: 8px 16px;
                gap: 10px;
            }}

            .nav-btn {{
                padding: 8px 12px;
                font-size: 12px;
            }}

            .page-indicator {{
                font-size: 14px;
                min-width: 60px;
            }}

            .keyboard-hint {{
                display: none;
            }}
        }}

        /* 로딩 애니메이션 */
        .loading {{
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            color: white;
            font-size: 18px;
        }}

        .loading::after {{
            content: '...';
            animation: dots 1.5s infinite;
        }}

        @keyframes dots {{
            0%, 20% {{ content: '.'; }}
            40% {{ content: '..'; }}
            60%, 100% {{ content: '...'; }}
        }}
    </style>
</head>
<body>
    <!-- 로딩 표시 -->
    <div class="loading" id="loading">페이지 로딩 중</div>

    <!-- 네비게이션 -->
    <div class="nav-controls">
        <button id="prev-btn" class="nav-btn">◀ 이전</button>
        <span id="page-indicator" class="page-indicator">1 / {total_pages}</span>
        <button id="next-btn" class="nav-btn">다음 ▶</button>
    </div>

    <!-- 키보드 단축키 안내 -->
    <div class="keyboard-hint">
        ← → 키로 페이지 이동 | ESC 전체화면 종료
    </div>

    <!-- 슬라이드 -->
    <div class="slides-container" id="slides-container">
{''.join(pages_html)}
    </div>

    <script>
        // 로딩 완료 후 숨김
        window.addEventListener('load', () => {{
            document.getElementById('loading').style.display = 'none';
        }});

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

        // 터치 스와이프 지원 (모바일)
        let touchStartX = 0;
        let touchEndX = 0;

        document.addEventListener('touchstart', e => {{
            touchStartX = e.changedTouches[0].screenX;
        }});

        document.addEventListener('touchend', e => {{
            touchEndX = e.changedTouches[0].screenX;
            handleSwipe();
        }});

        function handleSwipe() {{
            if (touchEndX < touchStartX - 50) showSlide(currentSlide + 1);
            if (touchEndX > touchStartX + 50) showSlide(currentSlide - 1);
        }}
    </script>
</body>
</html>
'''

    # 파일 저장
    with open(output_html, 'w', encoding='utf-8') as f:
        f.write(html_template)

    print(f"\n✅ HTML 생성 완료: {output_html}")

    # 파일 크기 계산
    file_size_mb = Path(output_html).stat().st_size / 1024 / 1024
    print(f"📊 파일 크기: {file_size_mb:.2f} MB")

    doc.close()
    return output_html


def main():
    if len(sys.argv) < 2:
        print("사용법: python pdf_to_image_html.py <PDF경로> [출력HTML경로] [DPI]")
        print("예시: python pdf_to_image_html.py proposal.pdf proposal_image.html 200")
        sys.exit(1)

    pdf_path = sys.argv[1]
    output_html = sys.argv[2] if len(sys.argv) > 2 else 'proposal_image.html'
    dpi = int(sys.argv[3]) if len(sys.argv) > 3 else 150

    pdf_to_image_html(pdf_path, output_html, dpi)


if __name__ == '__main__':
    main()
