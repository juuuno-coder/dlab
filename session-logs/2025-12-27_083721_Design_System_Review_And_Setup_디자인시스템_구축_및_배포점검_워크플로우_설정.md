Goal: 배포 전 안정성 확보를 위한 워크플로우 수립 및 디자인 시스템 페이지 구현/연동
Timeline:

- **배포 점검 프로세스 구축**: `.agent/workflows/deploy_check.md` 생성. (Lint, DB Migrate, Asset Build 자동화)
- **디자인 시스템 분석**: 기존 `tailwind.config.js`, `application.tailwind.css` 분석 후 리포트.
- **디자인 가이드 페이지 개발**:
  - `DesignSystemController` 생성.
  - `app/views/design_system/index.html.erb` 구현 (Color, Typography, Buttons, Cards, Forms 예시 포함).
  - `routes.rb`: `/design_system` 라우트 추가.
- **유기적 연결**: 메인 레이아웃(`application.html.erb`) 푸터에 '디자인 가이드' 링크 추가.
- **배포 및 버전 관리**: `feat: Add Design System page and footer link` 커밋 및 Push 완료.
  Insight:
- **운영 룰 정립**: 반복되는 실수 방지와 배포 안정성을 위해 `deploy_check` 워크플로우를 배포 직전에 반드시 수행하기로 함.
- **기술 스택 확인**: 프로젝트가 TypeScript가 아닌 Importmap 기반의 Rails 프로젝트임을 재확인하여 불필요한 TS 검사 공수를 줄임.
