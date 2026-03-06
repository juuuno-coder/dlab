#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
PDF → 이미지 변환 (각 페이지를 PNG로)
Claude가 시각적으로 확인하여 정확한 HTML 재현
"""

import os
from pdf2image import convert_from_path

PDF_PATH = r"d:\dev\dlab-site\knowledge-base\templates\260224_2026 부산 봄꽃 전시회 용역 제안.pdf"
OUTPUT_DIR = r"d:\dev\dlab-site\knowledge-base\templates\pdf_images"

# 출력 디렉토리 생성
os.makedirs(OUTPUT_DIR, exist_ok=True)

print("\n[*] PDF -> Images 변환 시작...\n")
print(f"[*] PDF: {PDF_PATH}")
print(f"[*] 출력 폴더: {OUTPUT_DIR}\n")

try:
    # PDF를 이미지로 변환 (200 DPI - 고품질)
    print("[*] PDF 변환 중... (시간이 걸릴 수 있습니다)\n")
    images = convert_from_path(PDF_PATH, dpi=200)

    print(f"[OK] 총 {len(images)}개 페이지 변환 완료\n")

    # 각 페이지를 PNG로 저장
    for i, image in enumerate(images, 1):
        output_path = os.path.join(OUTPUT_DIR, f"slide_{i:02d}.png")
        image.save(output_path, 'PNG')
        print(f"[OK] 슬라이드 {i:02d} 저장: {output_path}")

    print(f"\n[OK] 모든 이미지 저장 완료!")
    print(f"[FILE] 저장 위치: {OUTPUT_DIR}\n")
    print("다음 단계:")
    print("1. 생성된 이미지들을 Claude에게 보여주기")
    print("2. Claude가 시각적으로 확인하여 정확한 HTML 생성\n")

except Exception as e:
    print(f"[ERR] 변환 실패: {e}")
    print("\n해결 방법:")
    print("1. pip install pdf2image pillow")
    print("2. poppler 설치 (Windows): https://github.com/oschwartz10612/poppler-windows/releases/")
    print("   - poppler 다운로드 후 PATH 환경변수에 추가\n")
