# D.US (디어스) — Agency Platform

> **이 레포는 디어스(D.US / Designd) 플랫폼입니다.**
> 디랩(D.Lab) 에이전시 사이트는 → [vibers-leo/my-next-guide](https://github.com/vibers-leo/my-next-guide)

## 브랜드 정체성

**디어스(D.US)**는 에이전시 파트너들이 자신의 브랜드 사이트를 빠르게 구축하고 운영할 수 있도록 지원하는 **B2B SaaS 플랫폼**입니다.

## 핵심 기능

- **멀티 테넌시** — 무한 계층 에이전시 구조 (Root → Owner → Sub-owner)
- **자동 서브도메인 발급** — 결제 완료 시 자동으로 `site-XXXX.designd.co.kr` 생성
- **템플릿 마켓플레이스** — 업종별 고품질 디자인 템플릿 판매
- **에이전시 관리** — 하위 에이전시 생성/수수료 정산

## 기술 스택

| 분류 | 기술 |
|------|------|
| Backend | Ruby on Rails 8.1 |
| Frontend | Tailwind CSS, Stimulus JS, Turbo |
| Database | SQLite (개발) / PostgreSQL (프로덕션) |
| Auth | Devise + Google OAuth2 |
| 결제 | PortOne (Toss Payments) |
| 배포 | Fly.io (Docker) |

## 관련 브랜드

| 브랜드 | 역할 | 레포 |
|--------|------|------|
| **계발자들 (Vibers)** | 인재 허브, 협업 플랫폼 | vibers-leo/vibers |
| **디랩 (D.Lab)** | 종합 개발 에이전시 | vibers-leo/my-next-guide |
| **디어스 (D.US)** | 에이전시 SaaS 플랫폼 | 이 레포 |
| **팬이지 (FanEasy)** | 팬페이지 빌더 | vibers-leo/faneasy |

## 빠른 시작

```bash
bundle install
rails db:setup
rails server
```

배포: [FLY_DEPLOYMENT.md](./FLY_DEPLOYMENT.md) 참고
