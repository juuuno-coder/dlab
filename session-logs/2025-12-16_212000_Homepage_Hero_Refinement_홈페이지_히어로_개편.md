# Log: Homepage*Hero_Refinement (홈페이지*히어로\_개편)

Original Date: 2025-12-16 21:20:00
Key Goal: 메인 페이지 Hero 섹션을 '돈 벌어주는 홈페이지' 컨셉으로 전면 리뉴얼하고, 사용자 지정 3D 이미지 적용 및 반응형 레이아웃(PC/Mobile) 최적화

## 📝 상세 작업 일지 (Chronological)

### 1. Hero 섹션 메시지 및 디자인 기초 작업

- **상황**: 기존의 일반적인 에이전시 소개 문구를 직관적인 수익 창출 메시지로 변경 요청.
- **해결**:
  - `app/views/pages/home.html.erb`: 메인 타이틀을 "비싼 홈페이지? NO! 돈 벌어주는 홈페이지!"로 변경.
  - 서브 텍스트 수정 및 CTA 버튼을 '구독요금제 보기'로 변경하여 전환율 최적화.
  - 초기에는 CSS Animation을 활용한 3D 코인 아이콘을 도입했으나 이후 사용자 이미지로 교체 방향 전환.

### 2. 사용자 지정 3D 돈 이미지 적용 (Asset Integration)

- **상황**: 사용자가 보유한 특정 3D 돈다발 이미지를 Hero 섹션에 배치하고 애니메이션 효과 적용 요청.
- **해결**:
  - `public/images/`: `money.png` -> `money2.png` -> `money_final.png` (최종 초록색 돈다발) 순차적 업데이트 및 적용.
  - CSS Animation: `float-vertical` 키프레임을 정의하여 이미지가 둥둥 떠다니는 시각적 효과 구현.

### 3. 반응형 레이아웃(PC/Mobile) 고도화

- **상황**: 텍스트와 이미지가 겹치는 문제 해결 및 모바일/PC 환경별 최적화된 UX 필요.
- **해결**:
  - **PC Layout (Desktop)**:
    - 컨테이너 너비를 `max-width: 100%`로 확장하여 Full-width 레이아웃 구현.
    - 3단 Flex 구조([Spacer] - [Center Text] - [Right Image])를 도입하여 텍스트는 정중앙을 유지하되, 이미지는 우측 끝으로 배치하여 겹침 현상 원천 차단.
    - 텍스트 줄바꿈 방지(`white-space: nowrap`)를 통해 디자인 의도 유지.
  - **Mobile Layout**:
    - `[Text(Left)] - [Image(Right)]` 구조로 배치하고 이미지 크기를 130px로 확대하여 시인성 강화.

### 4. Stats Grid (통계 박스) 최적화

- **상황**: 모바일 화면에서 4개의 통계 박스가 세로로 길게 나열되어 스크롤 효율 저하 및 디자인 밸런스 붕괴.
- **해결**:
  - `app/views/pages/home.html.erb`: 모바일 뷰포트에서는 `.stat-card` 내부 아이템을 가로(`flex-direction: row`)로 한 줄 배치.
  - 박스의 높이를 줄이고 패딩을 조절하여 슬림하고 직관적인 인포그래픽 형태로 변경. (PC는 기존 세로형 유지)

### 5. 최종 리소스 정리

- **기술적 포인트**:
  - `ReplaceFileContent` 툴을 활용한 정밀한 DOM 조작.
  - Tailwind CSS와 Inline Style, Custom CSS Animation 복합 활용.
  - Git을 통한 단계별 버전 관리 및 배포.
