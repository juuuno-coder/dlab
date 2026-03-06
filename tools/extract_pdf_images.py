"""
PDF 각 페이지를 고해상도 이미지로 추출
HTML과 비교하기 위한 참조 이미지 생성
"""

import sys
from pathlib import Path
from pdf2image import convert_from_path
from PIL import Image

def extract_pdf_to_images(pdf_path, output_dir, dpi=150):
    """
    PDF를 이미지로 변환

    Args:
        pdf_path: PDF 파일 경로
        output_dir: 출력 디렉토리
        dpi: 해상도 (기본 150dpi, 고품질은 300dpi)
    """
    pdf_path = Path(pdf_path)
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    print(f"PDF → 이미지 변환 시작: {pdf_path.name}")
    print(f"출력 디렉토리: {output_dir}")
    print(f"해상도: {dpi} DPI")
    print("="*80)

    # PDF를 이미지로 변환 (poppler 필요)
    try:
        images = convert_from_path(
            pdf_path,
            dpi=dpi,
            fmt='png',
            thread_count=4
        )

        print(f"총 {len(images)}페이지 변환 중...")

        for i, image in enumerate(images, 1):
            output_path = output_dir / f"page_{i:02d}.png"
            image.save(output_path, 'PNG', optimize=True)
            print(f"저장: {output_path.name} ({image.width}x{image.height})", end='\r')

        print(f"\n\n변환 완료! {len(images)}개 이미지 저장됨")
        print(f"출력 위치: {output_dir}")

        return len(images)

    except Exception as e:
        print(f"\n오류 발생: {e}")
        print("\npoppler가 설치되어 있지 않을 수 있습니다.")
        print("설치 방법:")
        print("  Windows: https://github.com/oschwartz10612/poppler-windows/releases/")
        print("  macOS: brew install poppler")
        print("  Linux: sudo apt-get install poppler-utils")
        return 0


def main():
    if len(sys.argv) < 2:
        print("사용법: python extract_pdf_images.py <PDF경로> [출력디렉토리] [DPI]")
        print("예시: python extract_pdf_images.py proposal.pdf ./images 150")
        sys.exit(1)

    pdf_path = sys.argv[1]
    output_dir = sys.argv[2] if len(sys.argv) > 2 else './pdf_images'
    dpi = int(sys.argv[3]) if len(sys.argv) > 3 else 150

    extract_pdf_to_images(pdf_path, output_dir, dpi)


if __name__ == '__main__':
    main()
