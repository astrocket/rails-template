apply "config/application.rb"
apply "config/environments/development.rb"
apply "config/environments/production.rb"
apply "config/routes.rb"

template "config/database.yml.tt", force: true
copy_file 'config/initializers/sidekiq.rb'
copy_file 'config/sidekiq.yml'
copy_file 'config/initializers/slack.rb' if slack_notification == 'yes'