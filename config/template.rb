template "config/database.yml.tt"
copy_file 'config/initializers/sidekiq.rb'

inject_into_file 'config/environments/development.rb', before: /^end/ do
  <<-RUBY
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.perform_deliveries = true
  config.middleware.insert_after ActionDispatch::Static, Rack::LiveReload
  RUBY
end

inject_into_file 'config/application.rb', after: /class Application < Rails::Application/ do
  <<-RUBY
  config.active_job.queue_adapter = :sidekiq
  RUBY
end

inject_into_file 'config/routes.rb', before: /^end/ do
  <<-RUBY
  
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  namespace :api do
    
  end

  RUBY
end