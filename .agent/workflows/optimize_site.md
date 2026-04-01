---
description: Optimize site by linting, removing unused CSS, and checking DB migrations
---

1. Run RuboCop to lint Ruby code and auto-correct where possible.
   // turbo

```bash
bundle exec rubocop -A
```

2. Generate Rails stats to identify potential bottlenecks.

```bash
rails stats
```

3. Use PurgeCSS (or similar) to remove unused CSS from `application.css`.

```bash
npx purgecss --css app/assets/stylesheets/application.css --content "app/views/**/*.erb" --output app/assets/stylesheets/
```

4. Review the generated CSS file for any missing styles and commit changes.

5. Verify database migrations for redundant or duplicate tables.

```bash
rails db:migrate:status
```

6. Run the test suite to ensure no regressions.

```bash
bundle exec rspec
```
