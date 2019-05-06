#!/bin/sh
set -e

echo "bundle exec rake db:migrate..."
bundle exec rake db:migrate

echo "bundle exec sidekiq -C config/sidekiq.yml"
bundle exec sidekiq -C config/sidekiq.yml