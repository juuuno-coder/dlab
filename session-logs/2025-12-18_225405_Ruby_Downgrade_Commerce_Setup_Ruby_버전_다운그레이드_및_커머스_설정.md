Log: Ruby Version Downgrade & Commerce Setup (Ruby*버전*다운그레이드*및*커머스\_설정)
Original Date: 2025-12-18 22:54:05 (Estimated based on context)
Key Goal: Ruby 3.3에서 3.2로 다운그레이드하여 Windows 컴파일 오류 해결, SQLite/PostgreSQL 하이브리드 DB 설정, 상품 및 주문 기능(Toss Payments 연동) 구현

📝 상세 작업 일지 (Chronological)

1. Ruby 버전 다운그레이드 및 환경 설정

   - 상황: Windows 환경에서 Ruby 3.3.6 사용 시 `websocket-driver`, `pg` 등의 native gem 컴파일 오류 지속 발생.
   - 해결:
     - Ruby 버전을 3.2.9로 다운그레이드하고 PATH 환경변수 재설정.
     - `Gemfile` 및 `.ruby-version` 업데이트 (Ruby 3.2.9 명시).
     - 인코딩 문제 해결을 위해 `chcp 65001` 및 환경변수(`RUBYOPT="-Eutf-8"`) 설정 후 `bundle install` 수행.
     - 이전 버전(3.3)의 환경 변수 잔재(`RUBYLIB`, `GEM_HOME`)를 강제로 초기화하여 `rails` 명령어 실행 정상화.
     - `Gemfile`에서 `debug`, `bullet`, `image_processing`, `prawn`, `solid_cache`, `solid_queue` 등 Windows 충돌 유발 gem 비활성화.

2. 데이터베이스 설정 및 복구

   - 상황: Ruby 버전 변경 후 로컬 DB 연결 및 마이그레이션 필요.
   - 해결:
     - `database.yml` 설정 유지 (개발: SQLite, 운영: PostgreSQL).
     - `rails db:prepare` 수행 중 중복된 마이그레이션 이름(`UpdateCorporateTemplateUrls`) 충돌 발생.
     - `db/migrate/20251214070000_update_corporate_template_urls.rb` 파일 내용을 `20251214010000` 파일로 병합하고 중복 파일 삭제.
     - 3000번 포트 좀비 프로세스 강제 종료 후 서버 재시작하여 변경 사항 반영.

3. 커머스 기능 구현 (상품 및 주문)

   - 상황: 템플릿 판매를 위한 기본적인 쇼핑몰 기능 필요.
   - 해결:
     - `Product` 스캐폴드 생성: `name`, `description`, `price`, `stock`, `image_url` 필드.
     - `Order` 스캐폴드 생성: `product_id`, `customer_name`, `amount`, `status`, `payment_key`, `order_uid` 필드.
     - `products/show.html.erb`: Toss Payments SDK 연동 및 결제 UI 구현 (Tailwind CSS 적용).
     - `products/index.html.erb`: 상품 목록 페이지 그리드 레이아웃 적용.
     - `routes.rb`: `orders` 리소스에 `success`, `fail` 컬렉션 라우트 추가.
     - `OrdersController`: 결제 성공(`success`) 및 실패(`fail`) 액션 구현, 결제 정보로 주문 생성 로직 추가.

4. 관리자 페이지 도입 시도 (ActiveAdmin)
   - 상황: 상품 및 주문 관리를 위한 관리자 대시보드 필요.
   - 시도: `ActiveAdmin` 설치 시도 중 Windows 환경에서 `sassc` 및 `ffi` 젬 컴파일/로딩 오류 발생.
   - 조치: `sassc-rails` 교체 및 `ffi` 버전 다운그레이드 시도했으나 지속적인 오류로 중단, `RailsAdmin`으로 전환 논의 단계에서 종료.
