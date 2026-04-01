# PPT빌더

HTML 기반 슬라이드 템플릿 → JSON 스키마 → PPTX 자동 조립 시스템

---

## 프로젝트 구조

```
ppt-builder/
├── README.md              ← 이 파일
├── templates/             ← HTML 원본 (디자인 레퍼런스)
│   └── contents_two_column.html
├── schemas/               ← JSON 스키마 (디자인 + 데이터 규격)
│   └── contents_two_column.json
└── builder/               ← PPTX 생성 스크립트
    └── build_contents.js
```

---

## 작업 흐름

### 1. 좋은 슬라이드를 HTML로 확보

GenSpark에 슬라이드 스크린샷을 주고 요청:
> "이 슬라이드를 1280x907 고정 캔버스 HTML+인라인CSS로 재현해줘.
> 변수 부분은 {{placeholder}}로 표시해줘."

### 2. HTML → 스키마 변환 (Claude가 수행)

HTML을 분석해서 JSON 스키마를 생성:
- `design_system`: 색상, 폰트, 레이아웃 수치
- `pptx_mapping`: PptxGenJS 좌표 (인치 단위)로 변환
- `data_schema`: 콘텐츠 입력 규격
- `example_data`: 예시 데이터

### 3. 콘텐츠 작성 (AI가 수행)

RFP 분석 후 data_schema 형식에 맞춰 JSON 콘텐츠 작성.
제안서 전체 목차에 대해 슬라이드별로 적합한 템플릿 ID와 데이터를 매핑.

### 4. PPTX 자동 생성

```bash
node builder/build_contents.js data.json output.pptx
```

---

## HTML 가이드라인

GenSpark에서 HTML을 받을 때 지켜야 할 규칙:

### 캔버스
- 고정 크기: `width: 1280px; height: 907px`
- `overflow: hidden` 필수

### CSS
- 인라인 `<style>` 블록 사용 (외부 CSS 없음)
- 색상은 반드시 hex 코드 (#002B5B)
- px 단위 사용 (em/rem 불가)
- flexbox 레이아웃 권장

### 변수
- `{{variable_name}}` 형식으로 표시
- 반복 영역은 주석으로 표시: `<!-- REPEAT: sections -->`

### 네이밍
- 클래스명은 시맨틱하게: `.section-card`, `.header-section`
- 색상 관련 클래스: `.card-accent-navy`, `.card-accent-red`

---

## 등록된 템플릿

| ID | 이름 | 용도 | 상태 |
|----|------|------|------|
| `contents_two_column` | 목차 (2단 카드형) | 6개 섹션 목차 | ✅ 완성 |
| `title_cover` | 표지 | 제안서 표지 | ⏳ 대기 |
| `section_divider` | 섹션 구분 | 파트 전환 페이지 | ⏳ 대기 |
| `three_column_cards` | 3단 카드 | 전략/비교 레이아웃 | ⏳ 대기 |
| `table_layout` | 표 레이아웃 | 데이터 테이블 | ⏳ 대기 |
| `gantt_timeline` | 간트차트 | 일정 관리 | ⏳ 대기 |
| `closing` | 마무리 | 감사/기대효과 | ⏳ 대기 |

---

## 디자인 시스템 (선원의 날 기준)

### 색상 팔레트

| 용도 | 색상 | 코드 |
|------|------|------|
| 주색 (GOK Navy) | 🟦 | `#002B5B` |
| 보조 (Deep Blue) | 🟦 | `#004c8c` |
| 강조 (GOK Red) | 🟥 | `#C8102E` |
| 중립 (Gray) | ⬜ | `#6B7280` |
| 배경 (Light Gray) | ⬜ | `#f3f6f9` |

### 폰트 체계

| 용도 | 폰트 | 크기 | 굵기 |
|------|------|------|------|
| 페이지 타이틀 | Noto Sans KR | 36-42px | Bold |
| 섹션 제목 | Noto Sans KR | 24px | Bold |
| 본문 | Noto Sans KR | 14-16px | Regular |
| 캡션/페이지번호 | Noto Sans KR | 11-13px | Regular |

---

## 새 템플릿 추가하기

1. 좋은 슬라이드의 HTML을 `templates/` 에 저장
2. Claude에게 스키마 생성 요청:
   > "이 HTML을 분석해서 schemas/ 에 JSON 스키마 만들어줘"
3. Claude가 빌더 스크립트를 `builder/` 에 생성
4. 테스트 빌드 → QA → 등록 완료

---

## 향후 계획

- [ ] 전체 슬라이드를 순차 조립하는 마스터 빌더
- [ ] RFP 텍스트 → 자동 콘텐츠 생성 → 빌더 파이프라인
- [ ] 색상 팔레트 교체 (프로젝트별 톤앤매너 변경)
- [ ] 평가배점 자동 매칭 (키워드 바 자동 생성)
