apply "config/application.rb"
apply "config/environments/development.rb"
apply "config/environments/production.rb"
apply "config/routes.rb"

copy_file "config/initializers/sidekiq.rb"
copy_file "config/sidekiq.yml"
