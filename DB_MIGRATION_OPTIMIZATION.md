# 데이터베이스 마이그레이션 최적화 가이드

## 현재 상태

현재 `db/migrate` 폴더에 33개의 마이그레이션 파일이 존재하며, 대부분이 템플릿 이미지 URL 업데이트 관련입니다.

## 문제점

- 같은 목적(템플릿 이미지 URL 수정)의 마이그레이션이 여러 개 존재
- 마이그레이션 히스토리가 복잡하고 관리가 어려움
- 새로운 환경에서 `rails db:migrate` 실행 시 불필요한 시간 소요

## 중복 마이그레이션 목록

다음 마이그레이션들은 모두 템플릿 이미지 URL 업데이트를 수행합니다:

1. `20251214010000_update_corporate_template_urls.rb`
2. `20251214020000_fix_template_images_and_content.rb`
3. `20251214030000_update_fitness_template_urls.rb`
4. `20251214040000_update_beauty_template_urls.rb`
5. `20251214050000_update_dining_template_urls.rb`
6. `20251214060000_update_cafe_education_template_urls.rb`
7. `20251214070000_update_corporate_template_urls.rb` (중복)
8. `20251214080000_update_medical_law_template_urls.rb`
9. `20251214090000_update_stay_template_urls.rb`
10. `20251214100000_update_shopping_template_urls.rb`
11. `20251214110000_ensure_all_templates.rb`
12. `20251214150000_finalize_templates.rb`
13. `20251214170000_set_persistent_template_images.rb`
14. `20251215000000_apply_correct_korean_data.rb`
15. `20251215004500_update_template_images_v2.rb`
16. `20251215010000_update_missing_template_images.rb`
17. `20251215065100_fix_missing_template_images.rb`
18. `20251215070800_map_all_local_templates_to_images.rb`
19. `20251216153500_force_restore_template_images.rb`
20. `20251216154500_restore_all_original_images.rb`
21. `20251216180000_fix_specific_broken_images.rb`
22. `20251216181500_correct_template_images_ideally.rb`
23. `20251216183000_fix_aether_preview_url.rb`
24. `20251216201000_change_marketing_agency_image.rb`

## 권장 조치사항

### 옵션 1: 마이그레이션 통합 (프로덕션 배포 전)

**프로덕션에 아직 배포되지 않았다면** 다음 단계를 수행하세요:

1. 현재 개발 DB 백업

   ```bash
   cp db/development.sqlite3 db/development.sqlite3.backup
   ```

2. 모든 마이그레이션 롤백

   ```bash
   rails db:migrate:reset
   ```

3. 중복 마이그레이션 파일 삭제 (위 목록 참조)

4. 하나의 통합 마이그레이션 생성

   ```bash
   rails g migration CreateDesignTemplatesWithData
   ```

5. `db/quick_seed.rb`의 데이터를 마이그레이션에 포함

6. 마이그레이션 재실행
   ```bash
   rails db:migrate
   ```

### 옵션 2: 현재 상태 유지 (프로덕션 배포 후)

**이미 프로덕션에 배포되었다면** 마이그레이션을 그대로 유지하되:

1. 새로운 마이그레이션 생성 금지
2. 템플릿 데이터는 `db/seeds.rb` 또는 Admin 패널에서만 관리
3. 향후 스키마 변경만 마이그레이션으로 처리

## 현재 스키마 상태

`db/schema.rb`를 확인한 결과, 실제 DB에는 다음 테이블만 존재합니다:

- `portfolios`
- `quotes`

**`design_templates` 테이블이 스키마에 없습니다!**

이는 마이그레이션이 제대로 실행되지 않았거나, 스키마가 업데이트되지 않았음을 의미합니다.

## 즉시 조치 필요

1. `design_templates` 테이블 생성 마이그레이션 확인
2. 마이그레이션 상태 확인: `rails db:migrate:status`
3. 필요시 마이그레이션 재실행: `rails db:migrate`

## 향후 권장사항

- 데이터 변경은 마이그레이션이 아닌 `seeds.rb` 또는 Rake 태스크 사용
- 마이그레이션은 스키마 변경(테이블/컬럼 추가/삭제)에만 사용
- 이미지 URL 등 데이터는 Admin 패널에서 직접 관리
