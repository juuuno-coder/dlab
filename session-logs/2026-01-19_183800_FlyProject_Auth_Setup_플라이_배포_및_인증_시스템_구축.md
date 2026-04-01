# 세션 로그: Fly.io 배포 완료 및 인증 시스템 구축

**일시**: 2026-01-19 18:38
**참여자**: User, AI Assistant

## 1. 주요 작업 내용 요약

이번 세션에서는 `dlab-website`의 **Fly.io 정식 배포**를 완료하고, 운영 비용 효율화를 위해 **데이터베이스 재설정(SQLite Volume)** 및 **회원 기능(Google 로그인)** 구축을 시작했습니다.

### ✅ Fly.io 배포 및 도메인 연결 (완료)
1.  **커스텀 도메인 연결**:
    *   `www.designd.co.kr` 및 `designd.co.kr` (루트 도메인) 연결 성공.
    *   **SSL 인증서 발급 완료** (HTTPS 보안 접속 적용).
    *   Fly.io의 `ipv4` (A 레코드) 및 `_acme-challenge` CNAME을 통한 DNS 인증 해결.
2.  **서버 안정화**:
    *   초기 발생하던 502/403/500 에러 모두 해결.
    *   **메모리 최적화**: 1GB → 512MB로 축소하여 비용 절감 (Scale Down).

### ✅ 데이터베이스(DB) 인프라 재구축
1.  **기존 문제**: Render PostgreSQL 만료 및 비용 문제로 초기에는 'DB 없는 정적 모드'로 전환했음.
2.  **해결책 (Fly Volumes)**:
    *   Fly.io의 무료 **Block Storage (Volume) 1GB** 생성 (`dlab_storage`).
    *   `fly.toml`에 마운트 경로(`/rails/storage`) 설정.
    *   `database.yml`을 수정하여 **SQLite**를 프로덕션 DB로 사용하도록 변경.
    *   결과: **추가 비용 없이** 영구적인 데이터 저장이 가능한 '진짜 DB' 환경 구축 완료.

### 🚀 회원가입 및 인증 시스템 (진행 중)
1.  **Devise 라이브러리 설치**:
    *   Rails의 표준 인증 라이브러리인 `Devise` 설치.
    *   `User` 모델 및 테이블 생성 (`rails g devise User`).
2.  **Google 로그인 준비**:
    *   `omniauth-google-oauth2` 젬(Gem) 설치.
    *   구글 클라우드 콘솔(GCP)에서 **OAuth 클라이언트 ID/Secret** 발급 필요 상태.

---

## 2. 상세 작업 로그

### 2.1. 도메인 및 SSL 트러블슈팅
*   **문제**: 루트 도메인(`designd.co.kr`)의 AAAA 레코드 부재로 인증서 발급 지연.
*   **해결**: `_acme-challenge` CNAME 레코드를 추가하여 DNS 챌린지 방식으로 인증서 강제 발급 성공.

### 2.2. 서버 리소스 최적화
*   명령어: `fly scale memory 512 -a dlab-website`
*   결과: 메모리 할당량을 1GB에서 512MB로 줄여, 초기 서비스 운영에 적합한 가벼운 상태로 변경함.

### 2.3. Gemfile 라이브러리 정리
*   **프로덕션 DB**: `activerecord-nulldb-adapter` 제거(또는 미사용)하고 `sqlite3`를 글로벌 그룹으로 이동.
*   **인증 관련**: `devise`, `omniauth-google-oauth2`, `omniauth-rails_csrf_protection` 추가.

---

## 3. 다음 단계 (Next Steps)

1.  **Google OAuth 설정**:
    *   관리자로부터 GCP **Client ID** 및 **Client Secret** 수령 필요.
    *   `dlab-website` 환경 변수(`fly secrets set`)에 키 등록.
2.  **로그인 UI 구현**:
    *   "Google로 로그인" 버튼 배치.
    *   로그인 성공 시 헤더 UI 변경 (로그인/회원가입 → 내 정보/로그아웃).
3.  **데이터 검증**:
    *   실제 회원가입 시 SQLite DB 파일 (`/rails/storage/production.sqlite3`)에 유저 정보가 잘 저장되는지 확인.
