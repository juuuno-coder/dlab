# Log: Template*Refinement_And_Admin_Security (템플릿*개선*및*관리자\_보안)

Original Date: 2025-12-20 23:19:00 KST
Key Goal: 디자인 템플릿의 UI/UX 고도화(애니메이션, 한국형 UI), 배포 환경 오류 수정, 관리자 페이지 스팸 차단 및 편의 기능 구현

## 📝 상세 작업 일지 (Chronological)

### 1. AOS 애니메이션 및 템플릿 UI 개선

**상황:** 기존 템플릿이 정적이고 단조로워 사용자 경험(UX) 향상이 필요함. 한국 시장에 맞는 특화된 UI 요소(청첩장 D-Day, 펜션 예약 등)가 부재함.
**해결:**

- **`app/views/layouts/application.html.erb`**: AOS(Animate On Scroll) 라이브러리를 CDN으로 추가하고 전역 초기화 스크립트 작성.
- **`app/views/templates/wedding.html.erb`**:
  - 상단 D-Day 카운터(JS) 구현.
  - 네이버지도/카카오내비/티맵 바로가기 버튼 추가.
  - 축의금 계좌번호 아코디언 컴포넌트 추가.
- **`app/views/templates/pension.html.erb`**:
  - 모바일 환경(Quick Booking)을 위한 하단 고정 플로팅 바 추가.
  - 객실 미리보기용 가로 스크롤 슬라이더 및 인스타그램 그리드 구현.
- **`app/views/templates/ecommerce.html.erb`**:
  - 상품 카드 호버 시 퀵뷰(Quick View) 버튼 및 평점/리뷰 배지 노출.
  - 장바구니 아이콘 호버 시 미니 프리뷰 팝업 구현.
- **`app/views/templates/corporate.html.erb`**:
  - 상단 뉴스 티커(채용 정보 등) 마퀴(Marquee) 애니메이션 적용.
  - 핵심 지표(매출, 유저 수)에 숫자 카운팅(Increment) 애니메이션 적용.
  - 파트너사 로고 마퀴 섹션 추가.
- **`app/views/templates/medical.html.erb`**:
  - 히어로 섹션에 '빠른 상담 신청' 인라인 폼 추가.
  - 시술 전후 비교를 위한 'Before & After' 이미지 슬라이더(드래그 가능) 구현.

### 2. 배포 환경 수정 (Render Deployment Fix)

**상황:** Render 배포 시 `Gem::LoadError: pg is not part of the bundle` 에러 발생.
**해결:**

- **`Gemfile`**: 주석 처리되어 있던 `production` 그룹(`gem "pg"`, `gem "puma"`)의 주석 해제.
- **로컬 설정**: Windows 개발 환경 충돌 방지를 위해 `bundle config set --local without 'production'` 명령어로 로컬에서는 해당 젬들을 제외하도록 설정.

### 3. 보안 및 스팸 차단 (Security & Spam Protection)

**상황:** 문의 폼을 통한 스팸 메시지 유입 및 관리자 페이지 무차별 로그인 시도 우려.
**해결:**

- **`config/initializers/rack_attack.rb` 생성**:
  - **Contact Form**: 분당 3회 초과 요청 차단, 스팸 키워드(`casino`, `viagra`, `crypto` 등) 및 과도한 링크 포함 시 차단 로직 구현.
  - **Admin Login**: IP당 20초 내 5회 실패 시 차단(Brute-force 방지).
  - **Rate Limiting**: 일반 요청 IP당 5분 300회 제한.

### 4. 관리자 문의 내역 일괄 삭제 (Bulk Destroy)

**상황:** 스팸이나 테스트성 문의 데이터를 하나씩 삭제하는 불편함이 있음.
**해결:**

- **`app/controllers/admin/quotes_controller.rb`**:
  - `bulk_destroy` 액션 추가: `param[:quote_ids]`를 받아 일괄 삭제(`destroy_all`).
  - **Turbo 대응**: 삭제 후 `redirect_to` 호출 시 `status: :see_other` (HTTP 303)를 명시하여 Turbo Drive가 정상적으로 페이지를 갱신하도록 수정.
- **`app/views/admin/quotes/index.html.erb`**:
  - 각 카드에 체크박스 추가 및 전체 선택/해제 스크립트 구현.
  - 선택된 항목이 있을 때만 활성화되는 '선택 삭제' 버튼 배치.
