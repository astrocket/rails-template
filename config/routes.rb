insert_into_file 'config/routes.rb', before: /^end/ do
  if use_active_admin
  <<-'RUBY'
  authenticate :admin_user do
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'
  end

  namespace :api do

  end

  %w( 404 422 500 ).each do |code|
    get code, :to => "errors#show", :code => code
  end
  RUBY
  else
  <<-'RUBY'
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  namespace :api do

  end

  %w( 404 422 500 ).each do |code|
    get code, :to => "errors#show", :code => code
  end
  RUBY
  end
end