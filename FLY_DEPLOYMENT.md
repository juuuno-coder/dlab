# Fly.io 배포 가이드 - dlab-site

## 사전 준비

### 1. Fly.io CLI 설치 (PowerShell)
```powershell
iwr https://fly.io/install.ps1 -useb | iex
```

### 2. Fly.io 로그인
```bash
fly auth login
```

---

## 배포 과정

### 1. Fly.io 앱 초기화
```bash
cd d:\dev\dlab-site
fly launch
```

**대화형 질문 응답:**
- App Name: `dlab-site` (또는 원하는 이름)
- Region: `nrt` (Tokyo) 또는 `icn` (Seoul - 가능하면)
- PostgreSQL database: **Yes** ✅
- Redis: No (일단 필요 없음)

### 2. 환경변수 설정
```bash
# Rails master key 설정
fly secrets set RAILS_MASTER_KEY=$(cat config/master.key)

# 기타 필요한 환경변수
fly secrets set DATABASE_URL=postgresql://...
fly secrets set SECRET_KEY_BASE=$(bundle exec rails secret)
```

### 3. 데이터베이스 마이그레이션
```bash
# 최초 배포 후
fly ssh console
bundle exec rails db:migrate
bundle exec rails runner "load 'db/seeds/biddings.rb'"
exit
```

### 4. 배포
```bash
fly deploy
```

---

## 배포 후 확인

### 1. 앱 열기
```bash
fly open
```

### 2. 로그 확인
```bash
fly logs
```

### 3. SSH 접속 (문제 해결용)
```bash
fly ssh console
```

---

## 도메인 연결 (선택사항)

### 1. 커스텀 도메인 추가
```bash
fly certs add dlab.co.kr
fly certs add www.dlab.co.kr
```

### 2. DNS 레코드 설정
도메인 등록업체 (가비아 등)에서:
```
A 레코드: @ → [Fly.io IP]
CNAME: www → [앱이름].fly.dev
```

Fly.io IP 확인:
```bash
fly ips list
```

---

## fly.toml 설정 예시

```toml
app = "dlab-site"
primary_region = "nrt"

[build]

[http_service]
  internal_port = 3000
  force_https = true
  auto_stop_machines = true
  auto_start_machines = true
  min_machines_running = 0
  processes = ["app"]

[[vm]]
  cpu_kind = "shared"
  cpus = 1
  memory_mb = 512

[env]
  RAILS_ENV = "production"
  RAILS_LOG_TO_STDOUT = "true"
  RAILS_SERVE_STATIC_FILES = "true"

[[statics]]
  guest_path = "/app/public"
  url_prefix = "/"
```

---

## 문제 해결

### PostgreSQL 연결 오류
```bash
fly postgres attach [postgres-app-name]
```

### 앱 재시작
```bash
fly apps restart
```

### 스케일 조정 (필요시)
```bash
# 메모리 증가
fly scale memory 1024

# VM 증가
fly scale count 2
```

### 로컬에서 배포 테스트
```bash
# 프로덕션 환경 시뮬레이션
RAILS_ENV=production bundle exec rails assets:precompile
RAILS_ENV=production bundle exec rails s
```

---

## 비용

- **무료 티어**: 월 $5 크레딧 (충분함)
- **최소 구성**: 512MB RAM VM = 무료 범위 내
- **PostgreSQL**: 3GB 무료

---

## 예상 URL

배포 후 접속 가능한 URL:
- https://dlab-site.fly.dev (기본)
- https://dlab.co.kr (도메인 연결 시)

### 관리자 페이지
- https://dlab-site.fly.dev/admin
- https://dlab-site.fly.dev/admin/biddings ← 입찰사업 관리

---

**배포 전 체크리스트:**
- [ ] `config/master.key` 파일 존재 확인
- [ ] `bundle exec rails assets:precompile` 성공
- [ ] PostgreSQL 로컬 테스트 완료
- [ ] 환경변수 준비 (RAILS_MASTER_KEY 등)
