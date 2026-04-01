#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
PDF → 이미지 변환 (PyMuPDF 사용 - poppler 불필요)
"""

import fitz  # PyMuPDF
import os

PDF_PATH = r"d:\dev\dlab-site\knowledge-base\templates\260224_2026 부산 봄꽃 전시회 용역 제안.pdf"
OUTPUT_DIR = r"d:\dev\dlab-site\knowledge-base\templates\pdf_images"

# 출력 디렉토리 생성
os.makedirs(OUTPUT_DIR, exist_ok=True)

print("\n[*] PDF -> Images 변환 시작 (PyMuPDF)...\n")
print(f"[*] PDF: {PDF_PATH}")
print(f"[*] 출력 폴더: {OUTPUT_DIR}\n")

try:
    # PDF 열기
    pdf_document = fitz.open(PDF_PATH)
    total_pages = len(pdf_document)

    print(f"[OK] PDF 로드 완료 (총 {total_pages}개 페이지)\n")

    # 각 페이지를 PNG로 변환
    for page_num in range(total_pages):
        page = pdf_document[page_num]

        # 고해상도 변환 (2배 확대)
        mat = fitz.Matrix(2, 2)
        pix = page.get_pixmap(matrix=mat)

        # PNG로 저장
        output_path = os.path.join(OUTPUT_DIR, f"slide_{page_num + 1:02d}.png")
        pix.save(output_path)

        print(f"[OK] 슬라이드 {page_num + 1:02d} 저장 완료")

    pdf_document.close()

    print(f"\n[OK] 모든 이미지 저장 완료!")
    print(f"[FILE] 저장 위치: {OUTPUT_DIR}\n")
    print("다음 단계:")
    print("1. 생성된 이미지들을 Claude에게 보여주기")
    print("2. Claude가 시각적으로 확인하여 정확한 HTML 생성\n")

except Exception as e:
    print(f"[ERR] 변환 실패: {e}")
