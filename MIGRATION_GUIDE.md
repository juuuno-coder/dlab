# 디자인 템플릿 DB 마이그레이션 가이드

## 문제 상황

관리자 페이지에서 템플릿을 추가해도 공개 페이지에 표시되지 않는 경우

## 원인

DB 테이블에 필수 컬럼이 누락되어 있을 수 있습니다.

## 해결 방법

### 1. 마이그레이션 실행

```bash
rails db:migrate
```

이 명령은 다음 컬럼들을 추가합니다:

- `preview_url` (미리보기 URL)
- `image_url` (썸네일 이미지 URL)
- `is_featured` (메인 노출 여부)
- `view_count` (조회수)

### 2. 기존 데이터 확인

```bash
rails console
```

콘솔에서:

```ruby
# 템플릿 개수 확인
DesignTemplate.count

# 모든 템플릿 확인
DesignTemplate.all

# Featured 템플릿 확인
DesignTemplate.where(is_featured: true)
```

### 3. 샘플 데이터 추가 (선택사항)

```bash
rails db:seed
```

## 배포 시 자동 실행

Render.com에서는 배포 시 자동으로 다음 명령이 실행됩니다:

```bash
bundle install
rails db:migrate
rails db:seed
```

## 확인 방법

1. 관리자 페이지 (`/admin/design_templates`)에서 템플릿 추가
2. "메인 페이지에 노출하기" 체크
3. 저장
4. 메인 페이지 (`/`) 새로고침 → "검증된 디자인 템플릿" 섹션 확인
5. 템플릿 목록 (`/design_templates`) 확인

## 트러블슈팅

### 템플릿이 여전히 안 보이는 경우

1. Rails 서버 재시작
2. 브라우저 캐시 삭제 (Ctrl+Shift+R)
3. 콘솔에서 데이터 확인:
   ```ruby
   DesignTemplate.last
   ```

### 이미지가 안 보이는 경우

- `image_url` 필드에 올바른 URL 입력 확인
- 또는 PC 이미지 파일 업로드 확인
