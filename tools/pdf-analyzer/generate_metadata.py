#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
제안서 메타데이터 생성 도구
레이아웃 분석 결과 → proposal-slides용 메타데이터 JSON 변환
"""

import os
import sys
import json
from datetime import datetime

def infer_slide_type(elements, page_num):
    """
    페이지 요소들을 분석하여 슬라이드 타입 추론

    Args:
        elements: 페이지 요소 리스트
        page_num: 페이지 번호

    Returns:
        str: 슬라이드 타입
    """
    if page_num == 1:
        return "cover"

    # 요소 개수와 타입 분석
    heading_count = sum(1 for e in elements if e["type"].startswith("heading"))
    text_count = sum(1 for e in elements if e["type"] == "text")
    image_count = sum(1 for e in elements if e["type"] == "image")

    # 타입 추론 로직
    if heading_count >= 2 and text_count == 0:
        return "section"
    elif image_count >= 3:
        return "image-grid"
    elif image_count >= 1 and text_count >= 1:
        return "content-with-image"
    elif text_count >= 3:
        return "content"
    else:
        return "content"

def generate_slide_metadata(page_layout, page_num):
    """
    페이지 레이아웃 → 슬라이드 메타데이터 변환

    Args:
        page_layout: 페이지 레이아웃 정보
        page_num: 페이지 번호

    Returns:
        dict: 슬라이드 메타데이터
    """
    elements = page_layout.get("elements", [])
    slide_type = infer_slide_type(elements, page_num)

    # 제목 추출 (첫 번째 heading)
    title = ""
    for elem in elements:
        if elem["type"].startswith("heading"):
            title = elem["content"]
            break

    slide_meta = {
        "id": page_num,
        "type": slide_type,
        "title": title or f"슬라이드 {page_num}",
        "layout": "center" if slide_type == "cover" else "default",
        "elements": []
    }

    # 요소 변환
    for elem in elements:
        element_data = {
            "type": elem["type"],
            "bbox": elem["bbox"]
        }

        if "content" in elem:
            element_data["text"] = elem["content"]
        if "font_size" in elem:
            element_data["style"] = {
                "fontSize": elem["font_size"],
                "position": elem.get("position", "center")
            }
        if "width" in elem:
            element_data["size"] = {
                "width": elem["width"],
                "height": elem["height"]
            }

        slide_meta["elements"].append(element_data)

    return slide_meta

def generate_metadata(layout_file, output_file, title="제안서", client="", date=""):
    """
    레이아웃 JSON → 제안서 메타데이터 JSON 생성

    Args:
        layout_file: 레이아웃 JSON 파일
        output_file: 출력 메타데이터 JSON 파일
        title: 제안서 제목
        client: 클라이언트명
        date: 제안 날짜
    """
    print(f"\n[*] 제안서 메타데이터 생성 시작...")
    print(f"[*] 입력: {layout_file}\n")

    try:
        # 레이아웃 데이터 로드
        with open(layout_file, 'r', encoding='utf-8') as f:
            layout_data = json.load(f)

        # 제목 자동 추출 (첫 페이지의 첫 번째 큰 텍스트)
        if not title or title == "제안서":
            first_page = layout_data["pages"][0]
            for elem in first_page.get("elements", []):
                if elem["type"] in ["heading1", "heading2"]:
                    title = elem["content"]
                    break

        metadata = {
            "title": title,
            "client": client,
            "date": date or datetime.now().strftime("%Y-%m-%d"),
            "total_slides": layout_data["total_pages"],
            "generated_at": datetime.now().isoformat(),
            "source_pdf": layout_data["pdf_path"],
            "slides": []
        }

        # 각 페이지를 슬라이드 메타데이터로 변환
        for idx, page_layout in enumerate(layout_data["pages"], 1):
            slide_meta = generate_slide_metadata(page_layout, idx)
            metadata["slides"].append(slide_meta)
            print(f"[OK] 슬라이드 {idx}: type={slide_meta['type']}, elements={len(slide_meta['elements'])}")

        # JSON 저장
        os.makedirs(os.path.dirname(output_file) or '.', exist_ok=True)
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(metadata, f, ensure_ascii=False, indent=2)

        print(f"\n[OK] 메타데이터 생성 완료!")
        print(f"[FILE] 저장: {output_file}")
        print(f"\n제안서 정보:")
        print(f"  제목: {metadata['title']}")
        print(f"  클라이언트: {metadata['client']}")
        print(f"  날짜: {metadata['date']}")
        print(f"  슬라이드 수: {metadata['total_slides']}\n")

        return metadata

    except Exception as e:
        print(f"[ERR] 생성 실패: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

def main():
    if len(sys.argv) < 3:
        print("사용법: python generate_metadata.py <layout_json> <output_json> [title] [client] [date]")
        print("예시: python generate_metadata.py ./layout.json ./metadata.json \"봄꽃 전시회\" \"부산광역시\" \"2026-02-24\"")
        sys.exit(1)

    layout_file = sys.argv[1]
    output_file = sys.argv[2]
    title = sys.argv[3] if len(sys.argv) > 3 else "제안서"
    client = sys.argv[4] if len(sys.argv) > 4 else ""
    date = sys.argv[5] if len(sys.argv) > 5 else ""

    if not os.path.exists(layout_file):
        print(f"[ERR] 레이아웃 파일을 찾을 수 없습니다: {layout_file}")
        sys.exit(1)

    generate_metadata(layout_file, output_file, title, client, date)

if __name__ == '__main__':
    main()
