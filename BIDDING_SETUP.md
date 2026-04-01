# 입찰사업 관리 기능 설치 가이드

## 생성된 파일들

### 1. 데이터베이스
- `db/migrate/20260219000001_create_biddings.rb` - Bidding 테이블 마이그레이션
- `db/seeds/biddings.rb` - 샘플 데이터 5개

### 2. 모델 & 컨트롤러
- `app/models/bidding.rb` - Bidding 모델
- `app/controllers/admin/biddings_controller.rb` - 관리자 컨트롤러

### 3. 뷰 파일
- `app/views/admin/biddings/index.html.erb` - 목록 페이지 (짙은 파란색 디자인)
- `app/views/admin/biddings/show.html.erb` - 상세 페이지
- `app/views/admin/biddings/new.html.erb` - 신규 등록
- `app/views/admin/biddings/edit.html.erb` - 수정
- `app/views/admin/biddings/_form.html.erb` - 폼 partial

### 4. 라우팅
- `config/routes.rb` - admin 네임스페이스에 biddings 추가됨

---

## 설치 단계

### 1. DB 마이그레이션 실행
```bash
cd d:\dev\dlab-site
bundle install
bundle exec rails db:migrate
```

### 2. 샘플 데이터 추가
```bash
bundle exec rails runner "load 'db/seeds/biddings.rb'"
```

### 3. 로컬 서버 실행
```bash
bundle exec rails s
```

### 4. 접속 확인
브라우저에서 접속:
- http://localhost:3000/admin
- http://localhost:3000/admin/biddings

---

## 색상 변경 (디랩 브랜딩)

현재 **짙은 파란색** (#1E3A8A) 테마로 설정되어 있습니다.

### 변경하려면:
각 뷰 파일의 `<style>` 태그에서 다음 변수 수정:
```css
--primary-blue: #1E3A8A;  /* 짙은 파란색 */
--primary-light: #3B82F6; /* 밝은 파란색 */
```

---

## 다음 단계

### 1. 어드민 네비게이션에 메뉴 추가
어드민 레이아웃 파일 찾기:
- `app/views/layouts/admin.html.erb` 또는
- `app/views/admin/shared/_navigation.html.erb`

메뉴 항목 추가:
```erb
<%= link_to "리멘 협력사업", admin_biddings_path %>
```

### 2. 엑셀 데이터 연동 (선택사항)
현재는 샘플 데이터로 동작합니다.
실제 엑셀 데이터를 사용하려면:

```ruby
# db/seeds/biddings.rb 수정
require 'roo'

xlsx = Roo::Spreadsheet.open('d:/dev/dlab/hyupup/limen/2026년 리멘 입찰사업계획.xlsx')
# ... 엑셀 파싱 로직 추가
```

---

## 현재 샘플 데이터 (5개)

1. 2026년 AI 기반 디지털 전환 지원사업 (예정)
2. 지역 스마트시티 플랫폼 구축사업 (진행중, 30%)
3. AI 바우처 지원사업 (제출완료, 90%)
4. 공공데이터 활용 창업 지원사업 (예정, 10%)
5. SW마에스트로 과정 운영 용역 (예정)

---

## 문제 해결

### Bundle 명령어 없음
```bash
gem install bundler
```

### PostgreSQL 연결 오류
`config/database.yml` 확인

### 마이그레이션 오류
```bash
bundle exec rails db:reset
bundle exec rails db:migrate
```

---

**디자인**: 짙은 파란색 (#1E3A8A) 테마 적용됨
**URL**: localhost:3000/admin/biddings
