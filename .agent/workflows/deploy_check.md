---
description: Perform a pre-deployment check to catch errors and prevent regressions.
---

1. **Syntax & Style Check**:

   - Run `bundle exec rubocop` to catch Ruby syntax and style issues.
   - Check for ERB syntax errors.

2. **Database Migration Check**:

   - Run `bundle exec rails db:migrate:status` to ensure no pending migrations.

3. **Asset Build Check**:

   - Run `bundle exec rails assets:precompile` (dry run or actual) to verify assets build correctly.
   - Check if `esbuild` or `tailwind` builds complete without error.

4. **Common Error Patterns Check**:
   - Scan for common "gotchas" like missing closing tags, unpermitted parameters in controllers, or missing strict loading.
   - Review recent changes for potentially recurring issues.
