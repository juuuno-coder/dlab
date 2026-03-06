#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
PDF 레이아웃 분석 도구
페이지별 레이아웃 구조 분석 (제목, 본문, 이미지, 표 등)
"""

import os
import sys
import json
import fitz  # PyMuPDF

def rgb_to_hex(color_int):
    """RGB 정수를 HEX 색상 코드로 변환"""
    if color_int is None or color_int == 0:
        return "#000000"

    # PyMuPDF color는 RGB를 하나의 정수로 저장 (0xRRGGBB)
    r = (color_int >> 16) & 0xFF
    g = (color_int >> 8) & 0xFF
    b = color_int & 0xFF

    return f"#{r:02x}{g:02x}{b:02x}"

def get_font_flags(flags):
    """폰트 플래그에서 스타일 정보 추출"""
    styles = {
        "bold": bool(flags & 2 ** 4),
        "italic": bool(flags & 2 ** 1),
        "monospace": bool(flags & 2 ** 0),
    }
    return styles

def analyze_page_layout(page, page_num, output_dir=None):
    """
    페이지 레이아웃 분석 (개선 버전 - 폰트, 색상, 이미지 추출 포함)

    Args:
        page: fitz.Page 객체
        page_num: 페이지 번호
        output_dir: 이미지 저장 디렉토리 (선택)

    Returns:
        dict: 레이아웃 분석 결과
    """
    layout_info = {
        "page_number": page_num,
        "width": page.rect.width,
        "height": page.rect.height,
        "elements": []
    }

    # 텍스트 블록 분석
    blocks = page.get_text("dict")["blocks"]

    for block in blocks:
        if block.get("type") == 0:  # 텍스트 블록
            bbox = block["bbox"]
            text_content = ""

            # 모든 span 수집
            all_spans = []
            for line in block.get("lines", []):
                for span in line.get("spans", []):
                    text_content += span.get("text", "")
                    all_spans.append(span)

            text_content = text_content.strip()

            if not text_content:
                continue

            # 텍스트 블록의 위치 및 크기 분석
            x0, y0, x1, y1 = bbox
            width = x1 - x0
            height = y1 - y0

            # 첫 번째 span의 스타일 정보 (대표값)
            first_span = all_spans[0] if all_spans else {}
            font_size = first_span.get("size", 0)
            font_name = first_span.get("font", "Unknown")
            font_color = rgb_to_hex(first_span.get("color", 0))
            font_flags = get_font_flags(first_span.get("flags", 0))

            # 요소 유형 분류
            element_type = "text"
            if font_size >= 24:
                element_type = "heading1"
            elif font_size >= 18:
                element_type = "heading2"
            elif font_size >= 14:
                element_type = "heading3"
            elif y0 < page.rect.height * 0.15:
                element_type = "header"
            elif y0 > page.rect.height * 0.85:
                element_type = "footer"

            # 레이아웃 위치 분류
            layout_position = "center"
            if x0 < page.rect.width * 0.3:
                layout_position = "left"
            elif x0 > page.rect.width * 0.7:
                layout_position = "right"

            layout_info["elements"].append({
                "type": element_type,
                "content": text_content[:200],  # 처음 200자만
                "bbox": [round(x0, 2), round(y0, 2), round(x1, 2), round(y1, 2)],
                "font": {
                    "family": font_name,
                    "size": round(font_size, 2),
                    "color": font_color,
                    "bold": font_flags["bold"],
                    "italic": font_flags["italic"],
                },
                "position": layout_position
            })

        elif block.get("type") == 1:  # 이미지 블록
            bbox = block["bbox"]
            x0, y0, x1, y1 = bbox

            layout_info["elements"].append({
                "type": "image",
                "bbox": [round(x0, 2), round(y0, 2), round(x1, 2), round(y1, 2)],
                "width": round(x1 - x0, 2),
                "height": round(y1 - y0, 2)
            })

    # 이미지 추출 (선택적)
    if output_dir:
        extract_images_from_page(page, page_num, output_dir)

    return layout_info

def extract_images_from_page(page, page_num, output_dir):
    """페이지에서 이미지 추출"""
    image_list = page.get_images(full=True)

    if not image_list:
        return

    images_dir = os.path.join(output_dir, "images", f"page_{page_num:02d}")
    os.makedirs(images_dir, exist_ok=True)

    doc = page.parent

    for img_index, img_info in enumerate(image_list):
        xref = img_info[0]

        try:
            base_image = doc.extract_image(xref)
            image_bytes = base_image["image"]
            image_ext = base_image["ext"]

            image_filename = f"image_{img_index + 1:02d}.{image_ext}"
            image_path = os.path.join(images_dir, image_filename)

            with open(image_path, "wb") as img_file:
                img_file.write(image_bytes)

            print(f"    [이미지] {image_filename} 추출 완료")

        except Exception as e:
            print(f"    [경고] 이미지 {img_index + 1} 추출 실패: {e}")
            continue

def analyze_layout(pdf_path, output_file, extract_images=True):
    """
    PDF 전체 레이아웃 분석 (개선 버전)

    Args:
        pdf_path: PDF 파일 경로
        output_file: 출력 JSON 파일 경로
        extract_images: 이미지 추출 여부 (기본: True)
    """
    print(f"\n[*] PDF 레이아웃 분석 시작 (개선 버전)...")
    print(f"[*] PDF: {pdf_path}")
    print(f"[*] 이미지 추출: {'예' if extract_images else '아니오'}\n")

    try:
        pdf_document = fitz.open(pdf_path)
        total_pages = len(pdf_document)

        layout_data = {
            "pdf_path": pdf_path,
            "total_pages": total_pages,
            "pages": []
        }

        # 이미지 저장 디렉토리 (output_file과 같은 폴더)
        output_dir = os.path.dirname(output_file) if extract_images else None

        for page_num in range(total_pages):
            page = pdf_document[page_num]
            page_layout = analyze_page_layout(page, page_num + 1, output_dir)
            layout_data["pages"].append(page_layout)

            print(f"[OK] 페이지 {page_num + 1}: {len(page_layout['elements'])}개 요소 분석 완료")

        pdf_document.close()

        # JSON 저장
        os.makedirs(os.path.dirname(output_file) or '.', exist_ok=True)
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(layout_data, f, ensure_ascii=False, indent=2)

        print(f"\n[OK] 레이아웃 분석 완료!")
        print(f"[FILE] 저장: {output_file}")

        if extract_images and output_dir:
            images_dir = os.path.join(output_dir, "images")
            if os.path.exists(images_dir):
                print(f"[FILE] 이미지: {images_dir}/")

        print()

        return layout_data

    except Exception as e:
        print(f"[ERR] 분석 실패: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

def main():
    if len(sys.argv) < 3:
        print("사용법: python analyze_layout.py <pdf_path> <output_json>")
        print("예시: python analyze_layout.py proposal.pdf ./output/layout.json")
        sys.exit(1)

    pdf_path = sys.argv[1]
    output_file = sys.argv[2]

    if not os.path.exists(pdf_path):
        print(f"[ERR] PDF 파일을 찾을 수 없습니다: {pdf_path}")
        sys.exit(1)

    analyze_layout(pdf_path, output_file)

if __name__ == '__main__':
    main()
