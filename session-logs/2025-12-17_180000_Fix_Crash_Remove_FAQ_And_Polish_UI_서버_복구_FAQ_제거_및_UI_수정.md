Log: Fix*Crash_Remove_FAQ_And_Polish_UI (서버*복구*FAQ*제거*및\_UI*수정)
Original Date: 2025-12-17 18:00:00 KST
Key Goal: 프로덕션 서버 크래시 해결, FAQ/스팸 방지 기능 롤백, 문의 폼 에러 수정 및 브랜드/UI 텍스트 개선

📝 상세 작업 일지 (Chronological)

1. 긴급 서버 복구 (Hotfix)
   상황: Render 배포 후 `pg` gem 이슈 및 `faqs` 테이블 부재로 인해 앱 초기화 실패(503 에러).
   해결:

- `app/controllers/admin/dashboard_controller.rb`: FAQ 카운트 조회 시 예외 처리 추가.
- `app/controllers/pages_controller.rb`: 테이블 존재 여부 확인 후 FAQ 로드하도록 수정.

2. FAQ 및 스팸 방지 기능 완전 제거 (Revert)
   상황: DB 연동의 복잡성으로 인해 FAQ 관리 기능과 스팸 방지 기능을 제거하기로 결정.
   해결:

- **삭제 파일**: `FaqsController`, `Faq` 모델, `SpamFilter` 서비스, 관련 Views(`admin/faqs`), Migration, Seed.
- **코드 복원**:
  - `pricing.html.erb`: DB 연동 로직 제거 후 하드코딩된 FAQ로 복원.
  - `admin/dashboard/index.html.erb`: FAQ 통계 카드 및 링크 제거, 그리드 레이아웃 복원.
  - `routes.rb`: FAQ 리소스 라우팅 제거.
  - `layouts/admin.html.erb`: 사이드바 메뉴 제거.

3. 브랜드 리브랜딩 및 메타데이터 수정
   상황: 사이트 브랜드명을 '디랩'에서 '디어스'로 변경 요청.
   해결:

- `app/views/layouts/application.html.erb`: Open Graph 및 Twitter 메타 태그의 Description을 "디랩..."에서 "디어스..."로 일괄 수정.

4. 제작 의뢰(Contact) 페이지 오류 수정 (Critical)
   상황 1: 템플릿 문의(PICK) 시 서버 에러 발생. 원인은 삭제된 `SpamFilter`를 컨트롤러에서 계속 참조함.
   해결 1: `pages_controller.rb`의 `create_quote` 액션에서 스팸 체크 로직 완전 제거.
   상황 2: 폼 제출 시 `500 Internal Server Error` (ArgumentError) 발생.
   해결 2: `app/views/pages/contact.html.erb`의 `select_tag` 인자 개수 오류(4개 -> 3개) 수정. `class` 속성을 options 해시 내부로 이동.

5. UI/UX 및 텍스트 폴리싱
   상황: 홈페이지와 가격 페이지의 문구 및 스타일 개선 필요.
   해결:

- **Home (`home.html.erb`)**:
  - 히어로 섹션 카피 변경 ("합리적인..." -> "구독 요금제로 초기 개발비 부담은 낮추고...").
  - 버튼 순서 변경 (템플릿 보기 우선).
  - 통계 숫자 폰트 사이즈 조정을 위한 `.stat-number2` 클래스 추가 및 적용.
  - 서비스 설명 구체화 (E-커머스, 디자인 상세 등).
- **Pricing (`pricing.html.erb`)**:
  - "초기 세팅비" -> "초기 개발비" 용어 변경.
  - 프로 플랜 설명 수정 ("쇼핑몰 / 예약기능").
  - FAQ: 구독 중단 시 "무료버전 전환 및 광고 삽입" 문구 추가.
