source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.1"

# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"

# Use the Puma web server [https://github.com/puma/puma]
# Gem "puma" is handled in production group below to avoid Windows install issues locally
# gem "puma", ">= 5.0"

# Use PostgreSQL in production
group :production do
  gem "pg", "~> 1.6"
  gem "puma", ">= 5.0"
  gem "activerecord-nulldb-adapter"  # Allows builds without database connection
end

# Use SQLite globally (for production with Fly Volumes)
gem "sqlite3", ">= 2.1"

group :development, :test do
  gem "webrick"  # Web server for development (Windows compatible)
end

# Auth
gem "devise"
gem "omniauth-google-oauth2"
gem "omniauth-rails_csrf_protection"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem "tailwindcss-rails"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
# gem "solid_cache"
# gem "solid_queue"
# gem "solid_cable"  # Disabled - requires websocket-driver which has Windows compilation issues

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"

# PDF generation (선택사항 - Windows에서 설치 오류 시 주석 처리)
gem "prawn"
gem "prawn-table"

# Pagination
gem "kaminari"

# Rate limiting and spam protection
gem "rack-attack"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  # gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem "bundler-audit", require: false

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  # gem "rubocop-rails-omakase", require: false
  
  # N+1 query detection
  # gem "bullet"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  # gem "web-console"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
end

# Administration
# gem 'activeadmin'
# gem 'devise'
# gem 'sassc-rails'

# gem 'ffi', '1.16.3'

gem "dockerfile-rails", ">= 1.7", group: :development

gem "litestream", "~> 0.14.0"

gem "aws-sdk-s3", "~> 1.211", require: false

gem "instagram_basic_display", "~> 0.2.3"
