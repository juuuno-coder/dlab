#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
HWP 파일에서 텍스트를 추출하는 스크립트
"""
import sys
import os

def extract_with_olefile(hwp_path):
    """olefile로 HWP 텍스트 추출"""
    try:
        import olefile

        if not olefile.isOleFile(hwp_path):
            return None

        ole = olefile.OleFileIO(hwp_path)

        # HWP 5.x 형식
        if ole.exists('BodyText'):
            sections = []
            for i in range(100):  # 최대 100개 섹션
                section_name = f'BodyText/Section{i}'
                if ole.exists(section_name):
                    try:
                        data = ole.openstream(section_name).read()
                        # 간단한 텍스트 추출 (완벽하지 않음)
                        text = data.decode('utf-16le', errors='ignore')
                        sections.append(f"\n=== Section {i} ===\n{text}")
                    except:
                        pass
                else:
                    break
            ole.close()
            return '\n'.join(sections) if sections else None

        ole.close()
        return None
    except ImportError:
        return None
    except Exception as e:
        print(f"olefile 추출 실패: {e}", file=sys.stderr)
        return None

def extract_with_hwp5(hwp_path):
    """hwp5tools로 텍스트 추출"""
    try:
        from hwp5 import hwp5txt
        from io import StringIO

        output = StringIO()
        hwp5txt.main([hwp_path], output=output)
        text = output.getvalue()
        output.close()
        return text
    except ImportError:
        return None
    except Exception as e:
        print(f"hwp5tools 추출 실패: {e}", file=sys.stderr)
        return None

def extract_with_subprocess(hwp_path):
    """hwp5txt 명령줄 도구로 추출"""
    try:
        import subprocess
        result = subprocess.run(
            ['hwp5txt', hwp_path],
            capture_output=True,
            text=True,
            encoding='utf-8'
        )
        if result.returncode == 0:
            return result.stdout
        return None
    except FileNotFoundError:
        return None
    except Exception as e:
        print(f"hwp5txt 명령줄 실패: {e}", file=sys.stderr)
        return None

def main():
    if len(sys.argv) < 2:
        print("사용법: python extract_hwp_text.py <hwp_path> [output_path]")
        sys.exit(1)

    hwp_path = sys.argv[1]
    output_path = sys.argv[2] if len(sys.argv) > 2 else None

    if not os.path.exists(hwp_path):
        print(f"파일을 찾을 수 없습니다: {hwp_path}", file=sys.stderr)
        sys.exit(1)

    # 여러 방법 시도
    extractors = [
        ("hwp5txt CLI", extract_with_subprocess),
        ("hwp5tools", extract_with_hwp5),
        ("olefile", extract_with_olefile),
    ]

    text = None
    used_lib = None

    for lib_name, extractor in extractors:
        text = extractor(hwp_path)
        if text:
            used_lib = lib_name
            break

    if not text:
        print("HWP 파일을 읽을 수 없습니다.", file=sys.stderr)
        print("다음 중 하나를 설치하세요:", file=sys.stderr)
        print("  pip install hwp5", file=sys.stderr)
        print("  pip install olefile", file=sys.stderr)
        print("\n또는 HWP 파일을 PDF로 변환한 후 extract_pdf_text.py를 사용하세요.", file=sys.stderr)
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
