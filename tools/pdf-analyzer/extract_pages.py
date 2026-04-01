#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
PDF 페이지 추출 도구 (PyMuPDF)
각 페이지를 고해상도 PNG 이미지로 변환
"""

import fitz  # PyMuPDF
import os
import sys
import json

def extract_pages(pdf_path, output_dir, dpi=2):
    """
    PDF의 각 페이지를 PNG 이미지로 추출

    Args:
        pdf_path: PDF 파일 경로
        output_dir: 출력 디렉토리
        dpi: 해상도 배율 (기본 2 = 200dpi)

    Returns:
        dict: 추출된 페이지 정보
    """
    # 출력 디렉토리 생성
    os.makedirs(output_dir, exist_ok=True)

    print(f"\n[*] PDF 페이지 추출 시작...")
    print(f"[*] PDF: {pdf_path}")
    print(f"[*] 출력: {output_dir}")
    print(f"[*] 해상도: {dpi}x (기본 72dpi x {dpi} = {72 * dpi}dpi)\n")

    try:
        # PDF 열기
        pdf_document = fitz.open(pdf_path)
        total_pages = len(pdf_document)

        print(f"[OK] PDF 로드 완료 (총 {total_pages}개 페이지)\n")

        pages_info = {
            "pdf_path": pdf_path,
            "total_pages": total_pages,
            "output_dir": output_dir,
            "dpi": 72 * dpi,
            "pages": []
        }

        # 각 페이지를 PNG로 변환
        for page_num in range(total_pages):
            page = pdf_document[page_num]

            # 고해상도 변환 (dpi배 확대)
            mat = fitz.Matrix(dpi, dpi)
            pix = page.get_pixmap(matrix=mat)

            # PNG로 저장
            filename = f"page_{page_num + 1:02d}.png"
            output_path = os.path.join(output_dir, filename)
            pix.save(output_path)

            # 페이지 정보 저장
            page_info = {
                "page_number": page_num + 1,
                "filename": filename,
                "width": pix.width,
                "height": pix.height,
                "original_width": page.rect.width,
                "original_height": page.rect.height
            }
            pages_info["pages"].append(page_info)

            print(f"[OK] 페이지 {page_num + 1:02d} 추출 완료 ({pix.width}x{pix.height}px)")

        pdf_document.close()

        # 메타데이터 저장
        metadata_path = os.path.join(output_dir, "pages_metadata.json")
        with open(metadata_path, 'w', encoding='utf-8') as f:
            json.dump(pages_info, f, ensure_ascii=False, indent=2)

        print(f"\n[OK] 모든 페이지 추출 완료!")
        print(f"[FILE] 이미지: {output_dir}")
        print(f"[FILE] 메타데이터: {metadata_path}\n")

        return pages_info

    except Exception as e:
        print(f"[ERR] 추출 실패: {e}")
        sys.exit(1)

def main():
    if len(sys.argv) < 3:
        print("사용법: python extract_pages.py <pdf_path> <output_dir> [dpi_multiplier]")
        print("예시: python extract_pages.py proposal.pdf ./output/pages 2")
        sys.exit(1)

    pdf_path = sys.argv[1]
    output_dir = sys.argv[2]
    dpi = int(sys.argv[3]) if len(sys.argv) > 3 else 2

    if not os.path.exists(pdf_path):
        print(f"[ERR] PDF 파일을 찾을 수 없습니다: {pdf_path}")
        sys.exit(1)

    extract_pages(pdf_path, output_dir, dpi)

if __name__ == '__main__':
    main()
