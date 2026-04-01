"""
완벽한 PDF 파싱 엔진
PyMuPDF (fitz)를 사용하여 모든 디자인 요소 추출:
- 도형 (사각형, 원, 선) - 위치, 크기, 색상
- 텍스트 - 폰트, 크기, 굵기, 색상, 정확한 위치
- 이미지 - 위치, 크기, 이미지 데이터
- 배경 - 색상, 이미지
"""

import sys
import json
from pathlib import Path
import fitz  # PyMuPDF
from collections import defaultdict

class PerfectPDFParser:
    def __init__(self, pdf_path):
        self.pdf_path = Path(pdf_path)
        self.doc = fitz.open(pdf_path)
        self.analysis = {
            'metadata': {
                'total_pages': len(self.doc),
                'file_name': self.pdf_path.name,
            },
            'pages': []
        }

    def rgb_to_hex(self, rgb):
        """RGB 튜플을 HEX 색상 코드로 변환"""
        if rgb is None:
            return '#000000'

        # int인 경우
        if isinstance(rgb, (int, float)):
            # PyMuPDF는 RGB를 하나의 int로 인코딩: (R << 16) + (G << 8) + B
            if rgb > 255:  # RGB packed integer
                return f'#{int(rgb):06x}'
            else:  # Grayscale (0-1 또는 0-255)
                val = int(rgb * 255) if rgb <= 1 else int(rgb)
                return f'#{val:02x}{val:02x}{val:02x}'

        # 튜플/리스트인 경우
        if not isinstance(rgb, (tuple, list)) or len(rgb) < 3:
            return '#000000'

        r, g, b = int(rgb[0] * 255), int(rgb[1] * 255), int(rgb[2] * 255)
        return f'#{r:02x}{g:02x}{b:02x}'

    def extract_drawings(self, page):
        """페이지의 모든 도형(그리기) 추출"""
        drawings = []

        # PyMuPDF의 get_drawings()로 모든 벡터 그래픽 추출
        paths = page.get_drawings()

        for path in paths:
            items = path.get('items', [])
            rect = path.get('rect')
            fill = path.get('fill')
            color = path.get('color')
            width = path.get('width', 1)

            # 도형 타입 추정
            shape_type = 'path'
            if rect:
                # 사각형인지 확인
                if len(items) == 5:  # 사각형은 보통 5개 점
                    shape_type = 'rect'
                elif self._is_circle(items):
                    shape_type = 'circle'
                elif len(items) == 2:
                    shape_type = 'line'

            # items를 JSON 직렬화 가능하게 변환 (간단한 경로만)
            serializable_items = []
            for item in items[:10]:  # 너무 많으면 일부만
                if isinstance(item, (list, tuple)):
                    serializable_items.append([float(x) if isinstance(x, (int, float)) else str(x) for x in item])

            drawing = {
                'type': shape_type,
                'rect': {
                    'x': float(rect.x0) if rect else 0,
                    'y': float(rect.y0) if rect else 0,
                    'width': float(rect.width) if rect else 0,
                    'height': float(rect.height) if rect else 0
                },
                'fill_color': self.rgb_to_hex(fill) if fill else None,
                'stroke_color': self.rgb_to_hex(color) if color else None,
                'stroke_width': float(width) if width is not None else 1.0,
                'items': serializable_items  # JSON 직렬화 가능한 경로 데이터
            }

            drawings.append(drawing)

        return drawings

    def _is_circle(self, items):
        """경로가 원인지 판단"""
        # 간단한 휴리스틱: 여러 곡선 세그먼트로 구성되어 있으면 원일 가능성
        return len(items) > 4 and all(item[0] in ['c', 'curve'] for item in items if isinstance(item, (list, tuple)))

    def extract_text_details(self, page):
        """페이지의 모든 텍스트를 상세 정보와 함께 추출 (그룹화 개선)"""
        texts = []

        # get_text("dict")로 상세 정보 추출
        text_dict = page.get_text("dict")
        blocks = text_dict.get("blocks", [])

        for block in blocks:
            if block.get("type") != 0:  # 0 = 텍스트 블록
                continue

            for line in block.get("lines", []):
                # 같은 줄의 span들을 그룹화
                line_spans = []

                for span in line.get("spans", []):
                    if not span.get("text", "").strip():
                        continue

                    line_spans.append({
                        'text': span.get("text", ""),
                        'bbox': span.get("bbox"),
                        'font': span.get("font", ""),
                        'size': span.get("size", 12),
                        'flags': span.get("flags", 0),
                        'color': span.get("color", (0, 0, 0))
                    })

                if not line_spans:
                    continue

                # 같은 줄의 텍스트를 하나로 병합
                first_span = line_spans[0]
                last_span = line_spans[-1]

                merged_text = ' '.join([s['text'] for s in line_spans])

                # 병합된 bbox 계산
                x0 = first_span['bbox'][0]
                y0 = min([s['bbox'][1] for s in line_spans])
                x1 = last_span['bbox'][2]
                y1 = max([s['bbox'][3] for s in line_spans])

                # 대표 폰트/크기/색상 (첫 번째 span 기준)
                text_info = {
                    'text': merged_text,
                    'bbox': {
                        'x': x0,
                        'y': y0,
                        'width': x1 - x0,
                        'height': y1 - y0
                    },
                    'font': {
                        'name': first_span['font'],
                        'size': first_span['size'],
                        'flags': first_span['flags'],
                        'color': self.rgb_to_hex(first_span['color'])
                    },
                    'flags': {
                        'bold': bool(first_span['flags'] & 2**4),  # bit 4
                        'italic': bool(first_span['flags'] & 2**1),  # bit 1
                        'monospace': bool(first_span['flags'] & 2**3),
                    }
                }

                texts.append(text_info)

        return texts

    def extract_images(self, page):
        """페이지의 모든 이미지 추출"""
        images = []
        image_list = page.get_images(full=True)

        for img_info in image_list:
            xref = img_info[0]

            try:
                # 이미지 정보 가져오기
                base_image = self.doc.extract_image(xref)

                if base_image:
                    # 이미지 위치 찾기
                    try:
                        img_rect = page.get_image_bbox(img_info)
                    except:
                        # 위치를 찾을 수 없으면 기본값
                        img_rect = fitz.Rect(0, 0, base_image.get("width", 0), base_image.get("height", 0))

                    image_data = {
                        'xref': xref,
                        'bbox': {
                            'x': img_rect.x0 if img_rect else 0,
                            'y': img_rect.y0 if img_rect else 0,
                            'width': img_rect.width if img_rect else 0,
                            'height': img_rect.height if img_rect else 0
                        },
                        'ext': base_image.get("ext", "png"),
                        'width': base_image.get("width", 0),
                        'height': base_image.get("height", 0),
                        # 이미지 데이터는 나중에 별도 저장
                        'image_data': None  # base64로 인코딩 가능
                    }

                    images.append(image_data)
            except Exception as e:
                # 이미지 추출 실패 시 건너뛰기
                continue

        return images

    def detect_background(self, page, drawings):
        """배경 색상/이미지 감지"""
        # 페이지 전체를 덮는 큰 사각형을 배경으로 간주
        page_rect = page.rect

        background = {
            'color': '#ffffff',  # 기본 흰색
            'image': None
        }

        for drawing in drawings:
            if drawing['type'] == 'rect':
                rect = drawing['rect']
                # 페이지 크기의 90% 이상을 덮으면 배경으로 간주
                if (rect['width'] >= page_rect.width * 0.9 and
                    rect['height'] >= page_rect.height * 0.9):
                    if drawing['fill_color']:
                        background['color'] = drawing['fill_color']
                    break

        return background

    def parse_page(self, page_num):
        """단일 페이지 완벽 파싱"""
        page = self.doc[page_num - 1]

        print(f"파싱 중: 페이지 {page_num}/{len(self.doc)}", end='\r')

        # 모든 요소 추출
        drawings = self.extract_drawings(page)
        texts = self.extract_text_details(page)
        images = self.extract_images(page)
        background = self.detect_background(page, drawings)

        page_data = {
            'page_number': page_num,
            'dimensions': {
                'width': page.rect.width,
                'height': page.rect.height
            },
            'background': background,
            'drawings': drawings,
            'texts': texts,
            'images': images,
            'stats': {
                'drawing_count': len(drawings),
                'text_count': len(texts),
                'image_count': len(images)
            }
        }

        return page_data

    def parse_all(self):
        """전체 PDF 파싱"""
        print(f"완벽한 PDF 파싱 시작: {self.pdf_path.name}")
        print(f"총 {len(self.doc)}페이지")
        print("="*80)

        for page_num in range(1, len(self.doc) + 1):
            page_data = self.parse_page(page_num)
            self.analysis['pages'].append(page_data)

        print(f"\n파싱 완료!")
        return self.analysis

    def save_analysis(self, output_path):
        """분석 결과를 JSON으로 저장"""
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(self.analysis, f, ensure_ascii=False, indent=2)

        print(f"분석 결과 저장: {output_path}")

    def print_summary(self):
        """분석 요약 출력"""
        print("\n" + "="*80)
        print("디자인 요소 통계:")
        print("="*80)

        total_drawings = sum(p['stats']['drawing_count'] for p in self.analysis['pages'])
        total_texts = sum(p['stats']['text_count'] for p in self.analysis['pages'])
        total_images = sum(p['stats']['image_count'] for p in self.analysis['pages'])

        print(f"총 도형:   {total_drawings:5d}개")
        print(f"총 텍스트: {total_texts:5d}개")
        print(f"총 이미지: {total_images:5d}개")

        # 페이지별 요약
        print("\n" + "="*80)
        print("페이지별 요소 수:")
        print("="*80)
        print(f"{'페이지':<8} {'도형':<8} {'텍스트':<8} {'이미지':<8}")
        print("-"*80)

        for page in self.analysis['pages'][:10]:  # 처음 10페이지만
            print(f"{page['page_number']:<8} "
                  f"{page['stats']['drawing_count']:<8} "
                  f"{page['stats']['text_count']:<8} "
                  f"{page['stats']['image_count']:<8}")

        if len(self.analysis['pages']) > 10:
            print("... (나머지 페이지 생략)")

    def close(self):
        """리소스 정리"""
        self.doc.close()


def main():
    if len(sys.argv) < 2:
        print("사용법: python perfect_pdf_parser.py <PDF파일경로> [출력JSON경로]")
        sys.exit(1)

    pdf_path = sys.argv[1]
    output_path = sys.argv[2] if len(sys.argv) > 2 else pdf_path.replace('.pdf', '_perfect_analysis.json')

    parser = PerfectPDFParser(pdf_path)

    try:
        # 전체 파싱
        parser.parse_all()

        # 요약 출력
        parser.print_summary()

        # JSON 저장
        parser.save_analysis(output_path)

    finally:
        parser.close()


if __name__ == '__main__':
    main()
