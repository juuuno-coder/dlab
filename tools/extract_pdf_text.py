#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
PDF에서 텍스트를 추출하는 스크립트
"""
import sys
import os

def extract_with_pypdf2(pdf_path):
    """PyPDF2로 추출 시도"""
    try:
        import PyPDF2
        with open(pdf_path, 'rb') as file:
            reader = PyPDF2.PdfReader(file)
            text = ""
            for page_num, page in enumerate(reader.pages, 1):
                text += f"\n\n=== Page {page_num} ===\n\n"
                text += page.extract_text()
            return text
    except ImportError:
        return None
    except Exception as e:
        print(f"PyPDF2 추출 실패: {e}", file=sys.stderr)
        return None

def extract_with_pdfplumber(pdf_path):
    """pdfplumber로 추출 시도"""
    try:
        import pdfplumber
        text = ""
        with pdfplumber.open(pdf_path) as pdf:
            for page_num, page in enumerate(pdf.pages, 1):
                text += f"\n\n=== Page {page_num} ===\n\n"
                page_text = page.extract_text()
                if page_text:
                    text += page_text
        return text
    except ImportError:
        return None
    except Exception as e:
        print(f"pdfplumber 추출 실패: {e}", file=sys.stderr)
        return None

def extract_with_pymupdf(pdf_path):
    """PyMuPDF (fitz)로 추출 시도"""
    try:
        import fitz  # PyMuPDF
        doc = fitz.open(pdf_path)
        text = ""
        for page_num in range(len(doc)):
            page = doc[page_num]
            text += f"\n\n=== Page {page_num + 1} ===\n\n"
            text += page.get_text()
        doc.close()
        return text
    except ImportError:
        return None
    except Exception as e:
        print(f"PyMuPDF 추출 실패: {e}", file=sys.stderr)
        return None

def main():
    if len(sys.argv) < 2:
        print("사용법: python extract_pdf_text.py <pdf_path> [output_path]")
        sys.exit(1)

    pdf_path = sys.argv[1]
    output_path = sys.argv[2] if len(sys.argv) > 2 else None

    if not os.path.exists(pdf_path):
        print(f"파일을 찾을 수 없습니다: {pdf_path}", file=sys.stderr)
        sys.exit(1)

    # 여러 라이브러리 시도
    extractors = [
        ("pdfplumber", extract_with_pdfplumber),
        ("PyMuPDF", extract_with_pymupdf),
        ("PyPDF2", extract_with_pypdf2),
    ]

    text = None
    used_lib = None

    for lib_name, extractor in extractors:
        text = extractor(pdf_path)
        if text:
            used_lib = lib_name
            break

    if not text:
        print("모든 PDF 추출 라이브러리가 실패했습니다.", file=sys.stderr)
        print("다음 중 하나를 설치하세요:", file=sys.stderr)
        print("  pip install pdfplumber", file=sys.stderr)
        print("  pip install PyMuPDF", file=sys.stderr)
        print("  pip install PyPDF2", file=sys.stderr)
        sys.exit(1)

    # 출력
    if output_path:
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(text)
        # Windows 콘솔 인코딩 문제 회피
        try:
            sys.stdout.reconfigure(encoding='utf-8')
        except:
            pass
        print(f"✓ {used_lib}로 추출 완료: {output_path}")
    else:
        try:
            sys.stdout.reconfigure(encoding='utf-8')
        except:
            pass
        print(text)

if __name__ == "__main__":
    main()
