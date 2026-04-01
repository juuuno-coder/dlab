"""
제안서 자동 작성기
RFP 분석 결과 + 템플릿 학습 데이터를 기반으로 제안서 초안 작성
"""

import sys
import json
from pathlib import Path
from datetime import datetime


class ProposalWriter:
    def __init__(self, rfp_json_path, learning_json_path):
        # RFP 분석 결과 로드
        with open(rfp_json_path, 'r', encoding='utf-8') as f:
            self.rfp = json.load(f)

        # 학습 데이터 로드
        with open(learning_json_path, 'r', encoding='utf-8') as f:
            self.learning = json.load(f)

        self.proposal_content = {
            "메타정보": {},
            "섹션": []
        }

    def write_all(self):
        """전체 제안서 초안 작성"""
        print(f"[작성] 제안서 자동 작성 시작")
        print(f"[RFP] {self.rfp.get('사업명', self.rfp.get('사업개요', {}).get('사업명', '(사업명 없음)'))}")
        print("=" * 80)

        # 메타정보
        self._write_metadata()

        # 섹션별 작성
        sections = self.learning.get('학습내용', {}).get('섹션구조', [])

        for section in sections:
            print(f"\n[섹션] {section['제목']} 작성 중...")
            section_content = self._write_section(section)
            self.proposal_content["섹션"].append(section_content)

        print(f"\n[OK] 제안서 초안 작성 완료!")
        return self.proposal_content

    def _write_metadata(self):
        """메타정보 작성"""
        self.proposal_content["메타정보"] = {
            "제안서명": f"{self.rfp.get('사업명', '')} 제안서",
            "발주기관": self.rfp.get('발주처', {}).get('기관명', ''),
            "제안사": "주식회사디랩",
            "작성일": datetime.now().strftime('%Y년 %m월 %d일'),
            "예산": self.rfp.get('사업개요', {}).get('예산', ''),
            "행사일정": self.rfp.get('사업개요', {}).get('행사일정', ''),
            "행사장소": self.rfp.get('사업개요', {}).get('행사장소', ''),
            "주제": self.rfp.get('사업개요', {}).get('주제', ''),
            "RFP원본": self.rfp.get('메타정보', {}).get('원본파일', ''),
            "학습원본": self.learning.get('메타정보', {}).get('원본파일', '')
        }

    def _write_section(self, section):
        """섹션별 내용 작성"""
        section_title = section['제목']

        # 섹션 타입 판단
        if any(kw in section_title for kw in ['사업', '개요', 'Part Ⅰ']):
            return self._write_overview_section(section)
        elif any(kw in section_title for kw in ['추진', '계획', 'Part Ⅱ']):
            return self._write_plan_section(section)
        elif any(kw in section_title for kw in ['능력', '실적', '경험', 'Part Ⅲ']):
            return self._write_capability_section(section)
        elif any(kw in section_title for kw in ['예산', '비용', 'Part Ⅳ']):
            return self._write_budget_section(section)
        else:
            return self._write_generic_section(section)

    def _write_overview_section(self, section):
        """사업 개요 섹션 작성"""
        content = {
            "섹션제목": section['제목'],
            "내용": []
        }

        # 사업 배경
        사업명 = self.rfp.get('사업명', '')
        발주기관 = self.rfp.get('발주처', {}).get('기관명', '')
        주제 = self.rfp.get('사업개요', {}).get('주제', '')

        background = f"""
## 사업 배경

**{사업명}**는 {발주기관}에서 발주한 사업으로,
"{주제}"를 주제로 지역 문화 활성화와 시민 참여 확대를 목표로 합니다.

"""
        content["내용"].append(background)

        # 사업 목적 (학습 데이터의 강조 표현 활용)
        emphasis = self.learning.get('학습내용', {}).get('강조표현', [])
        sample_emphasis = emphasis[0] if emphasis else "성공적인 사업 수행"

        purpose = f"""
## 사업 목적

본 사업은 다음과 같은 핵심 목표를 달성하고자 합니다:

1. **지역 문화 활성화**: 시민들이 함께 즐기는 문화 축제
2. **경제 효과 창출**: 지역 상권과 연계한 경제 활성화
3. **차별화된 경험 제공**: {sample_emphasis}

"""
        content["내용"].append(purpose)

        return content

    def _write_plan_section(self, section):
        """추진 계획 섹션 작성"""
        content = {
            "섹션제목": section['제목'],
            "내용": []
        }

        # 일정
        schedule = self.rfp.get('일정', {})
        if schedule:
            schedule_text = f"""
## 사업 일정

- **사업 기간**: {schedule.get('기간', '미정')}
- **주요 마일스톤**:
  1. 사업 착수 및 기획
  2. 세부 실행 계획 수립
  3. 본 사업 실행
  4. 사업 마무리 및 결과보고

"""
            content["내용"].append(schedule_text)

        # 추진 조직
        organization = """
## 추진 조직

### 사업 총괄
- **PM(Project Manager)**: 전체 사업 총괄 및 품질 관리

### 실행팀
- **기획팀**: 사업 기획 및 콘텐츠 개발
- **운영팀**: 현장 운영 및 안전 관리
- **홍보팀**: 마케팅 및 홍보 전략 수립

"""
        content["내용"].append(organization)

        return content

    def _write_capability_section(self, section):
        """수행 능력 섹션 작성"""
        content = {
            "섹션제목": section['제목'],
            "내용": []
        }

        # 학습 데이터의 성공 사례 활용
        success_cases = self.learning.get('학습내용', {}).get('성공사례', [])

        intro = """
## 회사 소개

주식회사디랩은 AI 기술을 활용한 혁신적인 프로젝트 수행 경험을 보유한 전문 기업입니다.

"""
        content["내용"].append(intro)

        # 성공 사례
        if success_cases:
            cases_text = "## 주요 수행 실적\n\n"
            for i, case in enumerate(success_cases[:5], 1):
                cases_text += f"{i}. {case}\n"

            content["내용"].append(cases_text)

        # 차별화 전략 (학습 데이터의 강조 표현 활용)
        emphasis = self.learning.get('학습내용', {}).get('강조표현', [])
        diff_text = """
## 차별화 전략

"""
        if emphasis:
            for i, expr in enumerate(emphasis[:5], 1):
                diff_text += f"{i}. {expr}\n"
        else:
            diff_text += """
1. AI 기술을 활용한 효율적 사업 관리
2. 데이터 기반 의사결정 체계
3. 신속한 커뮤니케이션 시스템
"""

        content["내용"].append(diff_text)

        return content

    def _write_budget_section(self, section):
        """예산 섹션 작성"""
        content = {
            "섹션제목": section['제목'],
            "내용": []
        }

        budget = self.rfp.get('예산', {})

        budget_text = f"""
## 사업 예산

### 총 사업비
- **총 예산**: {budget.get('총예산', '미정')}

### 예산 구성 (예시)
| 항목 | 금액 | 비율 |
|------|------|------|
| 인건비 | 예산의 40% | 40% |
| 재료비 | 예산의 30% | 30% |
| 운영비 | 예산의 20% | 20% |
| 기타 | 예산의 10% | 10% |

※ 상세 내역은 사업 착수 후 조정 가능
"""

        content["내용"].append(budget_text)

        return content

    def _write_generic_section(self, section):
        """일반 섹션 작성"""
        content = {
            "섹션제목": section['제목'],
            "내용": []
        }

        # 하위 슬라이드 제목들을 기반으로 개요 작성
        subsections = section.get('하위슬라이드', [])

        if subsections:
            generic_text = f"## {section['제목']}\n\n"

            for sub in subsections:
                generic_text += f"### {sub['제목']}\n\n"
                generic_text += "(이 부분은 추가 작성이 필요합니다)\n\n"

            content["내용"].append(generic_text)

        return content

    def save_markdown(self, output_path):
        """제안서를 Markdown으로 저장"""
        output_file = Path(output_path)

        meta = self.proposal_content['메타정보']

        md_content = f"""# {meta.get('제안서명', '')}

---

**발주기관**: {meta.get('발주기관', '')}
**제안사**: {meta.get('제안사', '')}
**작성일**: {meta.get('작성일', '')}

**예산**: {meta.get('예산', '')}
**행사일정**: {meta.get('행사일정', '')}
**행사장소**: {meta.get('행사장소', '')}
**주제**: {meta.get('주제', '')}

---

"""

        # 섹션별 내용 추가
        for section in self.proposal_content['섹션']:
            md_content += f"\n# {section['섹션제목']}\n\n"

            for content_block in section['내용']:
                md_content += content_block + "\n"

        # 푸터
        md_content += """

---

**AI 작성 안내**: 이 제안서 초안은 AI가 자동으로 작성했습니다.
반드시 내용을 검토하고 수정한 후 사용하시기 바랍니다.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
🏢 주식회사디랩 (D.Lab Corp)
"""

        output_file.write_text(md_content, encoding='utf-8')

        print(f"\n[OK] 제안서 Markdown 저장: {output_file}")
        return output_file

    def save_json(self, output_path):
        """제안서를 JSON으로 저장"""
        output_file = Path(output_path)

        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(self.proposal_content, f, ensure_ascii=False, indent=2)

        print(f"제안서 JSON 저장: {output_file}")
        return output_file


def main():
    if len(sys.argv) < 3:
        print("사용법: python proposal_writer.py <RFP_JSON> <학습_JSON> [출력폴더]")
        print("예시: python proposal_writer.py rfp_analysis.json content_patterns.json output/")
        sys.exit(1)

    rfp_json = sys.argv[1]
    learning_json = sys.argv[2]
    output_dir = Path(sys.argv[3]) if len(sys.argv) > 3 else Path('.')
    output_dir.mkdir(exist_ok=True)

    writer = ProposalWriter(rfp_json, learning_json)
    writer.write_all()

    # Markdown 저장
    md_path = output_dir / "proposal_draft.md"
    writer.save_markdown(md_path)

    # JSON 저장
    json_path = output_dir / "proposal_draft.json"
    writer.save_json(json_path)

    print("\n완료! 다음 파일 생성:")
    print(f"  1. {md_path} (제안서 초안 - Markdown)")
    print(f"  2. {json_path} (제안서 초안 - JSON)")
    print(f"\n다음 단계: Markdown 파일을 검토/수정 후 PPT로 변환")


if __name__ == '__main__':
    main()
