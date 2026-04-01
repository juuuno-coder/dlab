#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
PDF 텍스트 추출 도구
텍스트 블록별로 추출 및 위치 정보 저장
"""

import fitz  # PyMuPDF
import os
import sys
import json

def extract_text_blocks(pdf_path, output_file):
    """
    PDF의 텍스트 블록을 추출하여 JSON으로 저장

    Args:
        pdf_path: PDF 파일 경로
        output_file: 출력 JSON 파일 경로

    Returns:
        dict: 텍스트 블록 정보
    """
    print(f"\n[*] PDF 텍스트 추출 시작...")
    print(f"[*] PDF: {pdf_path}\n")

    try:
        pdf_document = fitz.open(pdf_path)
        total_pages = len(pdf_document)

        text_data = {
            "pdf_path": pdf_path,
            "total_pages": total_pages,
            "pages": []
        }

        for page_num in range(total_pages):
            page = pdf_document[page_num]

            # 텍스트 블록 추출 (위치 정보 포함)
            blocks = page.get_text("dict")["blocks"]

            page_data = {
                "page_number": page_num + 1,
                "width": page.rect.width,
                "height": page.rect.height,
                "text_blocks": []
            }

            for block in blocks:
                # 텍스트 블록만 처리 (이미지는 제외)
                if block.get("type") == 0:  # type 0 = text
                    block_data = {
                        "bbox": block["bbox"],  # [x0, y0, x1, y1]
                        "lines": []
                    }

                    # 라인별로 텍스트 추출
                    for line in block.get("lines", []):
                        line_text = ""
                        spans_info = []

                        for span in line.get("spans", []):
                            line_text += span.get("text", "")
                            spans_info.append({
                                "text": span.get("text", ""),
                                "font": span.get("font", ""),
                                "size": round(span.get("size", 0), 2),
                                "color": span.get("color", 0),
                                "bbox": span.get("bbox", [])
                            })

                        block_data["lines"].append({
                            "text": line_text.strip(),
                            "bbox": line.get("bbox", []),
                            "spans": spans_info
                        })

                    # 빈 블록 제외
                    if any(line["text"] for line in block_data["lines"]):
                        page_data["text_blocks"].append(block_data)

            text_data["pages"].append(page_data)
            print(f"[OK] 페이지 {page_num + 1}: {len(page_data['text_blocks'])}개 텍스트 블록")

        pdf_document.close()

        # JSON 저장
        os.makedirs(os.path.dirname(output_file) or '.', exist_ok=True)
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(text_data, f, ensure_ascii=False, indent=2)

        print(f"\n[OK] 텍스트 추출 완료!")
        print(f"[FILE] 저장: {output_file}\n")

        return text_data

    except Exception as e:
        print(f"[ERR] 추출 실패: {e}")
        sys.exit(1)

def main():
    if len(sys.argv) < 3:
        print("사용법: python extract_text.py <pdf_path> <output_json>")
        print("예시: python extract_text.py proposal.pdf ./output/text.json")
        sys.exit(1)

    pdf_path = sys.argv[1]
    output_file = sys.argv[2]

    if not os.path.exists(pdf_path):
        print(f"[ERR] PDF 파일을 찾을 수 없습니다: {pdf_path}")
        sys.exit(1)

    extract_text_blocks(pdf_path, output_file)

if __name__ == '__main__':
    main()
