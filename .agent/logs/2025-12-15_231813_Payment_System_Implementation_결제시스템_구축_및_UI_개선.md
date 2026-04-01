Log: Payment System Implementation (결제시스템 구축 및 UI 개선)
Original Date: 2025-12-15 23:18
Key Goal: 메인 페이지 UI 개선, 이미지 로딩 로직 수정, 그리고 토스페이먼츠 기반의 상품/주문/구독 시스템 완벽 구현

📝 상세 작업 일지 (Chronological)

1. 메인 페이지 및 UI 개선 (UI Improvements)
   상황: 메인 페이지의 템플릿 카드 디자인이 서브 페이지와 다르고, 모바일 히어로 섹션의 균형이 맞지 않음.
   해결:

- app/views/pages/home.html.erb: 템플릿 카드 디자인을 통일(Hover 효과, '둘러보기' 및 'PICK' 버튼 추가). 모바일 히어로 섹션 패딩 및 텍스트 크기 조정. Stat 그리드 높이 통일.
  기술적 포인트: Tailwind CSS Grid 및 Flexbox를 활용한 반응형 디자인 통일.

2. 이미지 로딩 우선순위 수정 (Image Persistence Fix)
   상황: 배포 시 로컬에 저장된 템플릿 이미지가 ActiveStorage 이미지 우선 확인 로직 때문에 표시되지 않음.
   해결:

- app/views/pages/home.html.erb, app/views/design_templates/index.html.erb: 이미지 로드 순서를 `image_url`(로컬 경로) -> `pc_image`(업로드) 순으로 변경. `nil` 처리 로직 강화.
  기술적 포인트: ERB 조건부 렌더링 순서 변경을 통한 데이터 우선순위 조정.

3. 결제 시스템 기획 (Payment System Planning)
   상황: 상품 결제 및 유지보수 구독을 위한 시스템 필요. 관리자/사용자 분리 및 토스페이먼츠 연동 요청.
   해결:

- .agent/workflows/payment-system-plan.md: 개발 계획 수립 (Phase 1 ~ 5).

4. 회원 및 인증 시스템 구축 (User Authentication)
   상황: 결제 및 마이페이지 기능을 위한 회원 체계 부재.
   해결:

- Gemfile: `bcrypt` 활성화.
- db/migrate/20251216001500_create_users.rb: User 테이블 생성.
- app/models/user.rb: `has_secure_password`, 역할(admin/user) 구분 로직 추가.
- app/controllers/sessions_controller.rb: 통합 로그인 처리 (관리자는 어드민, 사용자는 마이페이지로 리다이렉트).
- app/controllers/users_controller.rb: 회원가입 처리.
- Views: 로그인(`sessions/new`), 회원가입(`users/new`) 페이지 구현.

5. 상품 및 주문 모델 구현 (Core Models)
   상황: 상품, 주문, 결제, 구독 데이터를 저장할 DB 구조 필요.
   해결:

- Migrations: `products`, `orders`, `payments`, `subscriptions` 테이블 생성.
- Models:
  - Product: 일회성/구독 타입 구분, JSON feature 목록 지원.
  - Order: 주문 번호 생성, 상태 관리.
  - Payment: 결제 정보 저장.
  - Subscription: 정기 결제 상태 및 기간 관리.

6. 토스페이먼츠 연동 (Payment Integration)
   상황: 실제 결제 승인 및 처리를 위한 PG 연동 필요.
   해결:

- app/services/toss_payments_service.rb: HTTParty를 이용한 결제 승인, 취소, 빌링키 발급 API 래퍼 구현.
- app/controllers/orders_controller.rb: 주문 생성 -> 결제 위젯 페이지 -> 성공/실패 콜백 처리 로직 구현.
- app/views/orders/show.html.erb: 토스페이먼츠 JS SDK 연동, 결제 위젯 렌더링.

7. 관리자 상품 관리 (Admin Products)
   상황: 관리자가 상품을 등록하고 수정할 UI 필요.
   해결:

- app/controllers/admin/products_controller.rb: 상품 CRUD 구현.
- app/views/admin/products/: 목록, 등록, 수정 폼 구현. subscription 타입에 따른 결제 주기 UI 동적 제어.

8. 마이페이지 구축 (MyPage)
   상황: 사용자가 자신의 주문 및 구독 내역을 확인해야 함.
   해결:

- app/controllers/mypage_controller.rb: 대시보드 및 하위 페이지 데이터 로드.
- View: 대시보드(`show`), 주문내역(`orders`), 구독관리(`subscriptions`), 프로필(`edit_profile`) 구현.
- Layout: 네비게이션 바(PC/Mobile)에 로그인 상태에 따른 링크(로그인/마이페이지) 분기 처리.

---

최종 결과:

- 메인 UI 일관성 확보 및 이미지 로딩 문제 해결.
- 토스페이먼츠 연동을 포함한 완벽한 쇼핑몰/구독 시스템 백엔드 및 프론트엔드 구축 완료.
