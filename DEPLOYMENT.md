# 디어스 웹사이트 배포 가이드

## 🚀 Render.com 배포 (추천)

### 1. GitHub 저장소 준비

```bash
# Git 초기화 (아직 안했다면)
git init
git add .
git commit -m "Initial commit: D.US website"

# GitHub에 푸시
git remote add origin https://github.com/your-username/dlab-website.git
git branch -M main
git push -u origin main
```

### 2. Render 계정 생성

1. https://render.com 접속
2. GitHub 계정으로 로그인

### 3. 새 Web Service 생성

1. **Dashboard** → **New +** → **Web Service**
2. GitHub 저장소 연결 (dlab-website)
3. 다음 설정 입력:

**Basic Settings:**

- **Name**: `dlab-website` (또는 원하는 이름)
- **Region**: `Singapore` (한국과 가까움)
- **Branch**: `main`
- **Root Directory**: 비워두기
- **Runtime**: `Ruby`
- **Build Command**:
  ```bash
  bundle install; bundle exec rake assets:precompile; bundle exec rake db:migrate
  ```
- **Start Command**:
  ```bash
  bundle exec puma -C config/puma.rb
  ```

**Environment:**

- **Plan**: `Free` 선택

### 4. 환경 변수 설정

**Environment Variables** 섹션에서 추가:

```
RAILS_ENV=production
RAILS_MASTER_KEY=<config/master.key 파일 내용>
ADMIN_USERNAME=admin
ADMIN_PASSWORD=your_secure_password_here
```

**중요:** `config/master.key` 파일의 내용을 복사해서 `RAILS_MASTER_KEY`에 입력하세요!

### 5. PostgreSQL 데이터베이스 생성

1. **Dashboard** → **New +** → **PostgreSQL**
2. 다음 설정:

   - **Name**: `dlab-website-db`
   - **Database**: `dlab_website`
   - **User**: `dlab_user`
   - **Region**: 웹 서비스와 동일한 지역
   - **Plan**: `Free`

3. 생성 후 **Internal Database URL** 복사

### 6. 데이터베이스 연결

Web Service의 Environment Variables에 추가:

```
DATABASE_URL=<PostgreSQL Internal Database URL>
CACHE_DATABASE_URL=<PostgreSQL Internal Database URL>
QUEUE_DATABASE_URL=<PostgreSQL Internal Database URL>
CABLE_DATABASE_URL=<PostgreSQL Internal Database URL>
```

### 7. 배포!

**Create Web Service** 버튼 클릭!

배포가 완료되면 `https://dlab-website.onrender.com` 같은 URL이 생성됩니다.

---

## 🔧 배포 후 작업

### 샘플 데이터 추가

Render Dashboard → Web Service → **Shell** 탭에서:

```bash
bundle exec rails db:seed
```

### 커스텀 도메인 연결 (선택사항)

1. Render Dashboard → Web Service → **Settings**
2. **Custom Domain** 섹션에서 도메인 추가
3. DNS 설정에 CNAME 레코드 추가

---

## 📝 업데이트 배포

코드 수정 후:

```bash
git add .
git commit -m "Update: 설명"
git push
```

Render가 자동으로 새 버전을 배포합니다!

---

## 🐛 문제 해결

### 배포 실패 시

1. **Logs** 탭에서 오류 확인
2. `RAILS_MASTER_KEY`가 올바른지 확인
3. 데이터베이스 URL이 올바른지 확인

### 데이터베이스 초기화

```bash
bundle exec rails db:reset
bundle exec rails db:seed
```

---

## 💡 대안: Railway.app

Render 대신 Railway도 좋은 선택입니다:

1. https://railway.app 접속
2. GitHub 저장소 연결
3. PostgreSQL 자동 프로비저닝
4. 환경 변수만 설정하면 끝!

**장점:**

- 더 빠른 빌드
- 더 나은 무료 플랜 (월 $5 크레딧)
- 슬립 모드 없음

---

## 🎯 배포 체크리스트

- [ ] GitHub에 코드 푸시
- [ ] Render 계정 생성
- [ ] Web Service 생성
- [ ] PostgreSQL 데이터베이스 생성
- [ ] 환경 변수 설정 (RAILS_MASTER_KEY 포함)
- [ ] 데이터베이스 URL 연결
- [ ] 배포 완료 확인
- [ ] 샘플 데이터 추가 (db:seed)
- [ ] 관리자 로그인 테스트
- [ ] 모든 페이지 동작 확인

---

**배포 완료 후 URL:** https://your-app-name.onrender.com

즐거운 배포 되세요! 🚀
