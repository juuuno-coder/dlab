# Implementation Plan - KICPA Style Accounting Template

이 문서는 사용자의 요청에 따라 한국공인회계사회(KICPA) 웹사이트의 디자인과 구조를 분석하여, 전문적인 회계/세무 법인용 웹사이트 템플릿(`Accounting`)을 신규 개발하는 계획을 담고 있습니다.

## 1. 목표 (Goal)

- **신뢰감 있는 디자인**: 공인회계사회의 전문성과 신뢰를 상징하는 블루/화이트 컬러 팔레트와 정돈된 Grid 레이아웃 적용.
- **정보 중심의 UI**: 뉴스, 공지사항, 홍보 센터 등 정보 전달에 최적화된 섹션 구성.
- **반응형 웹**: 데스크탑 및 모바일 환경 완벽 지원.

## 2. 주요 기능 및 페이지 구성 (Features)

- **Header**: 로고, GNB (메뉴), 검색, 로그인/회원가입 접근성 강화.
- **Hero Section**: 신뢰감을 주는 슬라이더 또는 히어로 이미지, 핵심 메시지 전달.
- **Quick Links (Service Icons)**: 주요 서비스(회계감사, 세무조정, 경영자문 등)로 바로 이동하는 아이콘 그리드.
- **News & Notice**: 탭(Tab) 형태의 최신 소식 및 공지사항 섹션.
- **Footer**: 관련 기관 배너, 사이트 맵, 카피라이트 등 표준 푸터.

## 3. 작업 단계 (Step-by-Step)

### Phase 1: 라우팅 및 컨트롤러 설정

- [ ] `config/routes.rb`: `/templates/accounting` 라우트 추가.
- [ ] `app/controllers/templates_controller.rb`: `accounting` 액션 추가.

### Phase 2: 뷰(View) 구현

- [ ] `app/views/templates/accounting.html.erb` 생성.
  - KICPA 스타일의 Header (Global Navigation).
  - Hero Section (이미지 + 텍스트).
  - Quick Menu (Grid Layout).
  - News/Notice Section.
  - Footer.
- [ ] Tailwind CSS를 사용하여 스타일링 (별도 CSS 파일 없이 Tailwind 유틸리티 클래스 적극 활용).

### Phase 3: 데이터 시딩 (Seeding)

- [ ] `db/seeds.rb`: 새로운 `Accounting` 템플릿 정보를 `DesignTemplate` 모델에 추가.
  - Title: "K-Accounting (공인회계)"
  - Category: "finance" (또는 "accounting")
  - Preview URL: `/templates/accounting`

### Phase 4: 확인 및 마무리

- [ ] 코드 린트 및 최종 점검.

## 4. 참고 사항

- 사용자의 로컬 서버 실행 문제(한글 경로)로 인해, 실제 브라우저 확인은 어려울 수 있으나 코드는 완벽하게 동작하도록 작성함.
- 디자인은 "법무법인 정의" 템플릿보다 좀 더 정보 전달과 공공기관 느낌을 강조함.
