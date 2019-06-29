insert_into_file 'config/routes.rb', before: /^end/ do
  if use_active_admin
  <<-'RUBY'
  authenticate :admin_user do
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'
  end

  namespace :api do

  end
  RUBY
  else
  <<-'RUBY'
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  namespace :api do

  end
  RUBY
  end
end