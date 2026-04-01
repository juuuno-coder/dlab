# 사이트 성능 최적화 체크리스트

## ✅ 완료된 최적화

### 1. CSS 최적화

- [x] PurgeCSS로 미사용 CSS 제거 (`purged.css` 생성)
- [x] 파일 크기: 15,376 → 14,829 bytes (약 5% 감소)
- [x] Footer 인라인 스타일을 CSS 클래스로 이동

### 2. HTML 최적화

- [x] Google Analytics 플레이스홀더 코드 제거
- [x] Footer 중복 인라인 스타일 제거
- [x] HTML 크기 약 500 bytes 감소

### 3. 컨트롤러 최적화

- [x] Featured templates 캐싱 적용 (1시간)
- [x] 에러 핸들링 구현
- [x] N+1 쿼리 문제 없음 확인

### 4. SEO 최적화

- [x] Meta 태그 완비 (Open Graph, Twitter Card)
- [x] robots.txt 구현
- [x] sitemap.xml 구현
- [x] DNS prefetch 설정

## 🔄 진행 중인 최적화

### 5. 데이터베이스 최적화

- [ ] 중복 마이그레이션 파일 정리 (24개 파일)
- [ ] `design_templates` 테이블 스키마 확인 필요
- [ ] 인덱스 추가 검토

## 📋 추가 권장 최적화

### 6. 이미지 최적화

**현재 상태:**

- Unsplash 이미지 사용 (외부 CDN)
- 로컬 이미지: `/images/money_final.png`, `/images/logo.png`

**권장 조치:**

```ruby
# Gemfile에 추가
gem 'image_processing', '~> 1.2'

# 이미지 최적화 헬퍼 사용
# app/helpers/image_optimization_helper.rb 이미 존재
```

**체크리스트:**

- [ ] 모든 이미지를 WebP 포맷으로 변환
- [ ] 이미지 lazy loading 적용 (`loading="lazy"`)
- [ ] 반응형 이미지 사용 (`srcset`)
- [ ] 이미지 압축 (TinyPNG, ImageOptim)

### 7. JavaScript 최적화

**현재 상태:**

- Tailwind CSS CDN 사용 (즉시 로드)
- 인라인 스크립트 사용

**권장 조치:**

- [ ] Tailwind CSS를 빌드 프로세스로 이동 (CDN 제거)
- [ ] JavaScript 번들링 (esbuild 또는 importmap)
- [ ] 사용하지 않는 JavaScript 제거
- [ ] 스크립트 지연 로딩 (`defer`, `async`)

### 8. 폰트 최적화

**현재 상태:**

- Google Fonts 사용 (Inter, Outfit)
- Pretendard CDN 사용

**권장 조치:**

- [ ] 폰트 서브셋 생성 (한글 + 영문만)
- [ ] `font-display: swap` 적용
- [ ] 로컬 폰트 호스팅 검토

### 9. 캐싱 전략

**현재 상태:**

- Featured templates 캐싱 (1시간)

**권장 조치:**

- [ ] 브라우저 캐싱 헤더 설정
- [ ] CDN 사용 검토 (Cloudflare)
- [ ] 정적 자산 캐싱 (CSS, JS, 이미지)
- [ ] Redis 캐싱 검토 (프로덕션)

### 10. 코드 분할 및 지연 로딩

**권장 조치:**

- [ ] 템플릿 미리보기 모달을 동적 로드
- [ ] 페이지별 JavaScript 분리
- [ ] Critical CSS 인라인 적용 (이미 일부 적용됨)

## 🎯 성능 목표

### Core Web Vitals

- **LCP (Largest Contentful Paint)**: < 2.5s
- **FID (First Input Delay)**: < 100ms
- **CLS (Cumulative Layout Shift)**: < 0.1

### 추가 지표

- **TTFB (Time to First Byte)**: < 600ms
- **Total Page Size**: < 1MB
- **Requests**: < 50

## 🛠️ 측정 도구

1. **Google PageSpeed Insights**: https://pagespeed.web.dev/
2. **GTmetrix**: https://gtmetrix.com/
3. **WebPageTest**: https://www.webpagetest.org/
4. **Chrome DevTools Lighthouse**

## 📊 현재 성능 스코어 (예상)

- **Performance**: 75-85 (개선 여지 있음)
- **Accessibility**: 90-95
- **Best Practices**: 85-90
- **SEO**: 95-100

## 🚀 우선순위 작업 (즉시 실행 가능)

### High Priority

1. ✅ CSS 최적화 (완료)
2. ✅ HTML 인라인 스타일 제거 (완료)
3. [ ] 이미지 lazy loading 적용
4. [ ] Tailwind CSS 빌드 프로세스로 이동

### Medium Priority

5. [ ] 폰트 최적화
6. [ ] JavaScript 번들링
7. [ ] 브라우저 캐싱 헤더 설정

### Low Priority

8. [ ] CDN 도입
9. [ ] Redis 캐싱
10. [ ] 코드 분할

## 📝 실행 명령어

### CSS 최적화 재실행

```bash
npx purgecss --css app/assets/stylesheets/application.css --content "app/views/**/*.erb" --output app/assets/stylesheets/purged.css
```

### 이미지 최적화

```bash
# ImageMagick 설치 후
mogrify -format webp -quality 85 app/assets/images/*.{jpg,png}
```

### 성능 측정

```bash
# Lighthouse CI
npm install -g @lhci/cli
lhci autorun --collect.url=https://your-site.com
```

## 🔍 모니터링

- [ ] Google Analytics 4 설정
- [ ] 에러 추적 (Sentry, Rollbar)
- [ ] 성능 모니터링 (New Relic, Scout APM)
