import sys
import re
from pathlib import Path

def analyze_proposal_structure(text_file):
    """제안서 텍스트 파일을 분석하여 페이지별 구조를 파악"""
    with open(text_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 페이지별로 분리
    pages = re.split(r'=== Page (\d+) ===', content)
    
    analysis = []
    
    for i in range(1, len(pages), 2):
        page_num = int(pages[i])
        page_content = pages[i+1].strip()
        
        # 각 페이지 분석
        lines = [line.strip() for line in page_content.split('\n') if line.strip()]
        
        # Part 섹션 확인
        part_match = re.search(r'Part [IⅠⅡⅢⅣ]+\.', page_content)
        part = part_match.group(0) if part_match else None
        
        # 주요 섹션 제목 찾기
        section_titles = []
        for line in lines[:10]:  # 앞부분만 확인
            if re.match(r'^\d+\)', line) or re.match(r'^[•\-]', line):
                continue
            if len(line) > 3 and len(line) < 100:
                section_titles.append(line)
        
        analysis.append({
            'page': page_num,
            'part': part,
            'titles': section_titles[:3],  # 상위 3개만
            'line_count': len(lines),
            'has_table': '구 분' in page_content or '프로그램명' in page_content,
            'has_list': '•' in page_content or '-' in page_content,
        })
    
    return analysis

if __name__ == '__main__':
    text_file = sys.argv[1] if len(sys.argv) > 1 else 'd:/dev/dlab-site/knowledge-base/templates/limen-bidding/최종제안서_extracted.txt'
    
    analysis = analyze_proposal_structure(text_file)
    
    print("=" * 80)
    print("제안서 구조 분석 결과")
    print("=" * 80)
    
    current_part = None
    for page in analysis:
        if page['part'] and page['part'] != current_part:
            current_part = page['part']
            print(f"\n{'='*80}")
            print(f"📑 {current_part}")
            print(f"{'='*80}")
        
        print(f"\n페이지 {page['page']:2d}: ", end='')
        if page['titles']:
            print(f"{' / '.join(page['titles'][:2])}")
        else:
            print("(제목 없음)")
        
        features = []
        if page['has_table']:
            features.append('표')
        if page['has_list']:
            features.append('리스트')
        if features:
            print(f"           특징: {', '.join(features)}")
    
    print("\n" + "="*80)
    print(f"총 {len(analysis)}페이지 분석 완료")
    print("="*80)

