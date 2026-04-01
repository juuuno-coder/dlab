set -o errexit

bundle install

# Precompile assets
bundle exec rails assets:precompile
bundle exec rails assets:clean
bundle exec rails db:migrate
