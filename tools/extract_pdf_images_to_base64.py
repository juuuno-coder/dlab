"""
PDF에서 이미지를 추출하여 base64로 인코딩
HTML에 직접 삽입 가능하도록
"""

import sys
import json
import base64
from pathlib import Path
import fitz  # PyMuPDF

def extract_images_with_base64(pdf_path, analysis_json_path, output_json_path):
    """
    PDF에서 이미지를 추출하고 base64로 인코딩하여 JSON에 추가
    """
    print("이미지 추출 시작...")

    # 분석 JSON 로드
    with open(analysis_json_path, 'r', encoding='utf-8') as f:
        analysis = json.load(f)

    # PDF 열기
    doc = fitz.open(pdf_path)

    # 이미지 추출 및 base64 인코딩
    image_cache = {}  # xref를 키로 사용하여 중복 방지

    total_images = 0

    for page_data in analysis['pages']:
        page_num = page_data['page_number']
        page = doc[page_num - 1]

        for img_info in page_data['images']:
            xref = img_info['xref']

            # 이미 처리한 이미지면 건너뛰기
            if xref in image_cache:
                img_info['image_data'] = image_cache[xref]
                continue

            try:
                # 이미지 추출
                base_image = doc.extract_image(xref)

                if base_image:
                    # 이미지 데이터를 base64로 인코딩
                    image_bytes = base_image['image']
                    image_ext = base_image['ext']

                    # MIME 타입 결정
                    mime_types = {
                        'png': 'image/png',
                        'jpg': 'image/jpeg',
                        'jpeg': 'image/jpeg',
                        'gif': 'image/gif',
                        'bmp': 'image/bmp'
                    }
                    mime_type = mime_types.get(image_ext, 'image/png')

                    # base64 인코딩
                    image_base64 = base64.b64encode(image_bytes).decode('utf-8')
                    data_url = f"data:{mime_type};base64,{image_base64}"

                    # 캐시에 저장
                    image_cache[xref] = data_url
                    img_info['image_data'] = data_url

                    total_images += 1
                    print(f"추출: 페이지 {page_num}, 이미지 {total_images}", end='\r')

            except Exception as e:
                print(f"\n이미지 추출 실패 (xref={xref}): {e}")
                img_info['image_data'] = None

    print(f"\n\n총 {total_images}개 이미지 추출 완료!")

    # 업데이트된 분석 데이터 저장
    with open(output_json_path, 'w', encoding='utf-8') as f:
        json.dump(analysis, f, ensure_ascii=False, indent=2)

    print(f"저장 완료: {output_json_path}")

    doc.close()


def main():
    if len(sys.argv) < 3:
        print("사용법: python extract_pdf_images_to_base64.py <PDF경로> <분석JSON경로> [출력JSON경로]")
        sys.exit(1)

    pdf_path = sys.argv[1]
    analysis_json_path = sys.argv[2]
    output_json_path = sys.argv[3] if len(sys.argv) > 3 else analysis_json_path.replace('.json', '_with_images.json')

    extract_images_with_base64(pdf_path, analysis_json_path, output_json_path)


if __name__ == '__main__':
    main()
