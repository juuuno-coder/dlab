#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
PDF 페이지 이미지 → HTML 슬라이드 (100% 시각적 재현)
각 페이지를 이미지로 표시하는 간단하지만 정확한 HTML 생성
"""

import os
import sys
import json

def create_image_slides_html(pages_dir, output_html, title="제안서", company=""):
    """
    페이지 이미지들을 HTML 슬라이드로 변환

    Args:
        pages_dir: 페이지 이미지 폴더
        output_html: 출력 HTML 파일
        title: 제안서 제목
        company: 회사명
    """
    print(f"\n[*] 이미지 기반 HTML 슬라이드 생성 시작...")
    print(f"[*] 이미지 폴더: {pages_dir}")
    print(f"[*] 출력 파일: {output_html}\n")

    # 메타데이터 파일 읽기 (있으면)
    metadata_file = os.path.join(pages_dir, "pages_metadata.json")
    total_pages = 0

    if os.path.exists(metadata_file):
        with open(metadata_file, 'r', encoding='utf-8') as f:
            metadata = json.load(f)
            total_pages = metadata.get("total_pages", 0)
    else:
        # 메타데이터 없으면 파일 개수로 카운트
        image_files = [f for f in os.listdir(pages_dir) if f.endswith('.png')]
        total_pages = len(image_files)

    print(f"[OK] 총 {total_pages}개 페이지 발견\n")

    # HTML 생성
    html_content = f"""<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{title}</title>
    <style>
        @import url('https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/variable/pretendardvariable.min.css');

        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}

        body {{
            background: #1a1a1a;
            font-family: 'Pretendard Variable', sans-serif;
            overflow-x: hidden;
            padding: 40px 0;
        }}

        .container {{
            max-width: 1400px;
            margin: 0 auto;
            padding: 0 20px;
        }}

        .header {{
            text-align: center;
            margin-bottom: 40px;
            color: white;
        }}

        .header h1 {{
            font-size: 32px;
            font-weight: 700;
            margin-bottom: 8px;
        }}

        .header p {{
            font-size: 16px;
            color: #999;
        }}

        .slides {{
            display: flex;
            flex-direction: column;
            gap: 40px;
            align-items: center;
        }}

        .slide {{
            background: white;
            box-shadow: 0 8px 32px rgba(0,0,0,0.3);
            border-radius: 8px;
            overflow: hidden;
            max-width: 100%;
            position: relative;
        }}

        .slide img {{
            width: 100%;
            height: auto;
            display: block;
        }}

        .slide-number {{
            position: absolute;
            bottom: 16px;
            right: 16px;
            background: rgba(0,0,0,0.7);
            color: white;
            padding: 8px 16px;
            border-radius: 4px;
            font-size: 14px;
            font-weight: 600;
        }}

        .controls {{
            position: fixed;
            bottom: 40px;
            right: 40px;
            display: flex;
            gap: 12px;
            z-index: 1000;
        }}

        .btn {{
            background: #0066CC;
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            box-shadow: 0 4px 12px rgba(0,102,204,0.3);
            transition: all 0.2s;
        }}

        .btn:hover {{
            background: #0052A3;
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(0,102,204,0.4);
        }}

        @media print {{
            body {{
                background: white;
                padding: 0;
            }}

            .header,
            .controls {{
                display: none;
            }}

            .slides {{
                gap: 0;
            }}

            .slide {{
                page-break-after: always;
                box-shadow: none;
                border-radius: 0;
                margin: 0;
            }}

            .slide-number {{
                display: none;
            }}
        }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>{title}</h1>
            <p>{company} · {total_pages}개 슬라이드</p>
        </div>

        <div class="slides" id="slides">
"""

    # 각 페이지 이미지 추가
    for page_num in range(1, total_pages + 1):
        image_filename = f"page_{page_num:02d}.png"
        image_path = os.path.join(os.path.dirname(output_html), os.path.basename(pages_dir), image_filename)

        # 상대 경로로 변환
        rel_path = os.path.relpath(os.path.join(pages_dir, image_filename), os.path.dirname(output_html))
        rel_path = rel_path.replace('\\', '/')  # Windows 경로 처리

        html_content += f"""            <div class="slide" id="slide-{page_num}">
                <img src="{rel_path}" alt="슬라이드 {page_num}" loading="lazy">
                <div class="slide-number">{page_num} / {total_pages}</div>
            </div>
"""

        print(f"[OK] 슬라이드 {page_num:02d} 추가")

    # HTML 마무리
    html_content += """        </div>
    </div>

    <div class="controls">
        <button class="btn" onclick="window.scrollTo({top: 0, behavior: 'smooth'})">↑ 맨 위로</button>
        <button class="btn" onclick="window.print()">🖨️ 인쇄/PDF</button>
    </div>

    <script>
        // 키보드 네비게이션
        let currentSlide = 0;
        const slides = document.querySelectorAll('.slide');

        document.addEventListener('keydown', (e) => {
            if (e.key === 'ArrowDown' || e.key === 'ArrowRight') {
                currentSlide = Math.min(currentSlide + 1, slides.length - 1);
                slides[currentSlide].scrollIntoView({ behavior: 'smooth', block: 'center' });
            } else if (e.key === 'ArrowUp' || e.key === 'ArrowLeft') {
                currentSlide = Math.max(currentSlide - 1, 0);
                slides[currentSlide].scrollIntoView({ behavior: 'smooth', block: 'center' });
            }
        });

        // 스크롤 시 현재 슬라이드 업데이트
        window.addEventListener('scroll', () => {
            const scrollPos = window.scrollY + window.innerHeight / 2;
            slides.forEach((slide, index) => {
                const rect = slide.getBoundingClientRect();
                const slideTop = rect.top + window.scrollY;
                const slideBottom = slideTop + rect.height;

                if (scrollPos >= slideTop && scrollPos <= slideBottom) {
                    currentSlide = index;
                }
            });
        });
    </script>
</body>
</html>
"""

    # 파일 저장
    os.makedirs(os.path.dirname(output_html) or '.', exist_ok=True)
    with open(output_html, 'w', encoding='utf-8') as f:
        f.write(html_content)

    print(f"\n[OK] HTML 슬라이드 생성 완료!")
    print(f"[FILE] {output_html}")
    print(f"\n✅ 100% 시각적으로 동일한 슬라이드가 생성되었습니다.")
    print(f"📌 브라우저에서 열어보세요: {os.path.basename(output_html)}\n")

def main():
    if len(sys.argv) < 3:
        print("사용법: python create_image_slides.py <pages_dir> <output_html> [title] [company]")
        print("예시: python create_image_slides.py ./analysis/pages ./output/slides.html \"제안서\" \"주식회사디랩\"")
        sys.exit(1)

    pages_dir = sys.argv[1]
    output_html = sys.argv[2]
    title = sys.argv[3] if len(sys.argv) > 3 else "제안서"
    company = sys.argv[4] if len(sys.argv) > 4 else ""

    if not os.path.exists(pages_dir):
        print(f"[ERR] 페이지 이미지 폴더를 찾을 수 없습니다: {pages_dir}")
        sys.exit(1)

    create_image_slides_html(pages_dir, output_html, title, company)

if __name__ == '__main__':
    main()
