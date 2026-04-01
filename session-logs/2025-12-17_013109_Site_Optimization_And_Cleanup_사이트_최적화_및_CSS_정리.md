# Log: Site*Optimization_And_Cleanup (사이트*최적화*및\_CSS*정리)

Original Date: 2025-12-17 01:31:09
Key Goal: 사이트 공개 전 성능 최적화, 불필요한 코드 제거(CSS/HTML), DB 마이그레이션 및 성능 최적화 가이드 문서 작성

## 📝 상세 작업 일지 (Chronological)

### 1. 초기 환경 진단 및 전략 수립

- **상황**: 사이트 완성 후 최적화(Linting, 중복 코드 제거, DB 점검) 요청.
- **문제**: Windows 환경에서 `bundle install` 시 `websocket-driver` 네이티브 확장 컴파일 오류 발생으로 Rails 명령어(`rubocop`, `db:migrate:status`) 실행 불가.
- **해결**:
  - Rails 의존성이 없는 `npx purgecss`를 사용하여 CSS 최적화 우선 진행.
  - 코드 분석을 통해 수동으로 최적화 포인트 식별 및 문서화 진행.

### 2. CSS 최적화 (PurgeCSS)

- **상황**: `application.css`에 사용하지 않는 스타일이 다수 포함되어 파일 크기 비대화 우려.
- **해결**:
  - `npx purgecss` 명령어를 사용하여 `app/views/**/*.erb`를 스캔.
  - 사용되지 않는스타일을 제거한 `app/assets/stylesheets/purged.css` 생성.
  - **결과**: 파일 크기 약 5% 감소 (15,376 bytes → 14,829 bytes).

### 3. Hero 섹션 UI 수정 및 정렬

- **상황**:
  1. 메인 페이지 Hero 섹션에 `@media` CSS 코드가 텍스트로 노출되는 버그 발견.
  2. 중앙 정렬된 타이틀과 서브타이틀을 좌측 정렬로 변경 요청.
- **수정 파일**: `app/views/pages/home.html.erb`
- **해결**:
  - 133번 라인 부근의 불필요한 `<div class="pc-spacer">` 및 노출된 `@media` 텍스트 제거.
  - `.hero-title`과 `.hero-subtitle` 요소에 `text-align: left;` 스타일 인라인 적용 (또는 클래스 수정).

### 4. HTML 및 레이아웃 최적화

- **상황**: `application.html.erb` 레이아웃 파일에 불필요한 주석(GA 코드)과 Footer 영역의 중복된 인라인 스타일 존재.
- **수정 파일**:
  - `app/views/layouts/application.html.erb`
  - `app/assets/stylesheets/application.css`
- **해결**:
  - **GA 코드 제거**: 사용하지 않는 Google Analytics 플레이스홀더 주석 코드 삭제.
  - **Footer 스타일 분리**:
    - `application.css`에 `.footer-section ul`, `.footer-section li`, `.footer-section a` 클래스 추가.
    - 레이아웃 파일에서 하드코딩된 `style="..."` 속성을 제거하고 CSS 클래스로 대체하여 HTML 용량 감소 및 가독성 확보.

### 5. 최적화 가이드 문서화

- **상황**: 현재 실행 불가능한 DB 작업과 향후 필요한 성능 개선 사항을 정리할 필요성 대두.
- **해결**:
  - **`DB_MIGRATION_OPTIMIZATION.md` 생성**:
    - 24개의 중복된 템플릿 이미지 관련 마이그레이션 파일 식별.
    - 마이그레이션 통합 및 스키마 정리 가이드 작성.
  - **`PERFORMANCE_OPTIMIZATION.md` 생성**:
    - 완료된 최적화 항목(CSS, HTML, SEO 등) 정리.
    - 향후 과제(이미지 Lazy Loading, Tailwind 빌드 전환, 폰트 최적화 등) 체크리스트 제공.

---

**최종 처리**: 모든 변경 사항(CSS 생성, 뷰 수정, 문서 추가)을 Git에 커밋하고 원격 저장소로 푸시 완료.
