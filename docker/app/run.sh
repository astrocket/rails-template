#!/bin/sh
set -e

echo "bundle exec rake db:migrate..."
bundle exec rake db:migrate

echo "bin/rails s -p 3000 -b '0.0.0.0'..."
rm -f tmp/pids/server.pid
bin/rails s -p 3000 -b '0.0.0.0'
