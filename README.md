# 🚀 디어스 (D.US) - Global SaaS & Agency Platform

AI와 현대적 디자인이 조화된 프리미엄 웹 에이전시 플랫폼, **디어스(D.US)**입니다. 
이 프로젝트는 단순한 홍보 사이트를 넘어, **무한 계층 멀티 테넌시(Tiered Multi-tenancy)**와 **자동화된 사이트 프로비저닝** 기술을 결합한 비즈니스 솔루션입니다.

---

## ✨ 핵심 특장점 (Technical Highlights)

### 1. 🏢 무한 계층 멀티 테넌시 (Recursive Agency Architecture)
*   **구조**: `DLAB (Root) ➔ Owner (Partner) ➔ Sub-owner (User) ➔ ...` 형태의 무한 계층 구조를 지원합니다.
*   **특징**: 상위 에이전시는 하위 에이전시의 활동과 회원을 관리하고 수익을 공유받을 수 있는 비즈니스 로직이 기저에 설계되어 있습니다.

### 2. ⚡ 자동화된 사이트 프로비저닝 (Full-Automated Lifecycle)
*   **Flow**: 사용자가 디자인 템플릿을 선택하고 결제(`Order`)를 완료하는 즉시, 시스템은 해당 사용자를 `Owner` 권한으로 격상시키며 전용 `Agency`(독립된 관리 공간)를 자동으로 생성합니다.
*   **무설정(Zero-config)**: 결제 완료와 동시에 관리자 패널이 활성화되어 즉시 비즈니스를 시작할 수 있습니다.

### 3. 🛡️ 고도화된 권한 기반 제어 (Advanced RBAC)
*   **데이터 격리**: 에이전시 관리자는 본인의 에이전시 및 하위 에이전시에 귀속된 유저, 주문, 상담 내역만 접근 가능하도록 엄격하게 격리되어 있습니다.
*   **다중 관리자 지원**: 하나의 에이전시에 다수의 관리자(`admin_ids`)를 지정하여 공동 운영이 가능한 협업 구조를 갖추고 있습니다.

### 4. 🌐 서브도메인 기반 컨텍스트 감지 (Context-Aware Routing)
*   **자동 귀속**: `influencer.designd.co.kr`와 같은 서브도메인을 통해 접근한 유저는 가입 시 자동으로 해당 에이전시의 '팬(회원)'으로 등록됩니다.
*   **동적 UI**: 접속 경로에 따라 에이전시별 맞춤형 테마나 설정을 동적으로 로드할 수 있는 프레임워크가 구축되어 있습니다.

### 5. 💎 프리미엄 디자인 시스템 (Rich Aesthetics)
*   **Aesthetics**: Glassmorphism, Dynamic Animations, Sleek Dark Mode 등 현대적인 웹 디자인 트렌드가 바닐라 CSS 기반으로 밀도 있게 구현되었습니다.
*   **Responsive**: 모든 기능은 모바일 프레임과 PC 뷰에서 완벽하게 동작하며, 라이브 데모 미리보기 기능을 내장하고 있습니다.

---

## 🛠️ 기술 스택 (Tech Stack)

*   **Core**: Ruby on Rails 8.1 (Modern Standard)
*   **Architecture**: Multi-tenant Shared Database (Agile & Scalable)
*   **Frontend**: Vanilla CSS Design System, Importmaps, Turbo Drive
*   **Payment**: PortOne (Toss Payments) Standard Integration
*   **Storage**: Active Storage (Local/Cloud Hybrid)
*   **Deploy**: Fly.io (Dockerized Deployment)

---

## 📁 모델 아키텍처 (Core Models)

*   **User**: `super_admin`, `owner`, `admin`, `user` 권한 체계 및 Google OAuth 연동
*   **Agency**: 서브도메인, 소유자, 부모-자식 관계, 수수료 설정(`commission_rate`)
*   **Order/Quote**: 결제 및 견적 시스템, 에이전시 자동 연결 로직 내장
*   **DesignTemplate**: 판매용 고퀄리티 템플릿 정보 및 카테고리 관리

---

## 🚀 빠른 시작 (Quick Start)

본 프로젝트를 참고용으로 클론하거나 풀링한 경우, 다음 과정을 통해 핵심 로직을 테스트할 수 있습니다.

1.  **초기 설정**: `bundle install && rails db:prepare`
2.  **테스트 유저 생성**: `rails console`에서 유저 생성 후 `role: 'owner'` 부여
3.  **에이전시 생성**: 해당 유저를 소유자로 하는 `Agency` 생성 (subdomain 필수)
4.  **관리자 접속**: `/admin` 경로로 접속하여 본인 소유 에이전시의 대시보드 확인

---

## 📞 문의 및 기술 협력

이 플랫폼의 아키텍처나 추가적인 기능 확장(수수료 자동 정산, API 연동 등)에 대해 궁금한 점이 있다면 언제든 문의해 주세요.

- **Developer**: Antigravity AI @ DLAB
- **Website**: [dlab-website.fly.dev](https://dlab-website.fly.dev/)

---
*© 2026 DLAB. Crafted with passion for scalable business.*
