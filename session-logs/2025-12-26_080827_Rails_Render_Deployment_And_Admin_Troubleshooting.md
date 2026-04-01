Log: Rails_Render_Deployment_And_Admin_Troubleshooting
Date: 2025-12-26 08:08:27
Key Goal: "디어스(D.US)" Rails 앱의 Render.com 배포 완료 및 어드민 페이지 500 에러 해결

📝 상세 작업 일지 (Chronological)

1. Git 저장소 설정 및 GitHub 연동
   상황: 로컬 프로젝트를 GitHub에 업로드하고 Render.com과 연동해야 함.
   해결:

- `git init`, `git add .`, `git commit` 수행
- GitHub Remote 추가 및 `git push`

2. Database 마이그레이션 (SQLite -> PostgreSQL)
   상황: Render.com 배포를 위해 Production DB를 SQLite에서 PostgreSQL로 변경 필요.
   해결:

- `Gemfile`: `sqlite3`를 development/test 그룹으로 이동, production 그룹에 `pg` 추가.
- `config/database.yml`: `adapter: postgresql`로 변경 및 `DATABASE_URL` 환경변수 사용 설정.

3. Render.com 배포 환경 설정 및 트러블슈팅
   상황: 배포 과정에서 `Gemfile.lock` 플랫폼 불일치, DB 연결 오류, Build Command 오류 발생.
   해결:

- **Platform Issue**: Build Command에 `bundle lock --add-platform x86_64-linux` 추가.
- **Rake Task Issue**: `bundle exec rake`가 테스트용 `debug` gem을 로드하려다 실패함. -> `bundle exec rake db:migrate`(또는 `assets:precompile` 포함)로 명시적 변경.
- **DB Connection**: Render의 `DATABASE_URL`이 Internal URL로 잘못 설정되어 접속 불가 -> External Database URL로 변경하여 `DATABASE_URL`, `CACHE_DATABASE_URL` 등 4개 변수 업데이트.

4. Tailwind CSS 적용 시도 및 롤백
   상황: 사용자가 Tailwind CSS 적용을 원했으나 설정 파일 부재 및 경로 문제로 빌드 실패 (`assets/tailwind/application.css` not found).
   해결:

- Tailwind 관련 설정 파일 생성 및 `manifest.js` 등 수정 시도했으나 지속적인 빌드 오류.
- **Rollback**: 안정적인 배포를 위해 기존 `application.css`(`propshaft`) 방식으로 롤백 결정.
- `app/views/layouts/application.html.erb`: stylesheet 태그를 `tailwind`에서 `application`으로 복구.

5. 어드민 페이지 500 에러 해결
   상황: 배포 후 어드민 페이지(`/admin`) 접속 시 500 에러 발생. 로그 상 `The asset 'tailwind.css' was not found` 오류 확인.
   해결:

- 원인: `app/views/layouts/admin.html.erb` 파일이 여전히 존재하지 않는 `tailwind.css` (또는 잘못된 `:app` 심볼)를 참조하고 있었음.
- 수정: `stylesheet_link_tag "application"`으로 수정하여 올바른 에셋을 로드하도록 변경.
- 결과: 변경 사항 Git Push 후 재배포하여 정상 접속 확인.

6. 어드민 접속 정보 확인
   상황: 어드민 비밀번호 분실.
   해결:

- Render 환경변수 `ADMIN_PASSWORD` 확인 가이드 제공 (기본값 `password123` 또는 설정된 `elwkdlselfoq1!` 확인).
