insert_into_file 'config/routes.rb', before: /^end/ do
  if use_active_admin
  <<-'RUBY'
  authenticate :admin_user do
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'
  end
  RUBY
  else
  <<-'RUBY'
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
  RUBY
  end

  namespace :api do
    get '/' => 'home#index'
  end

  if use_react
  <<-'RUBY'
  # To render react packs for any path except app/api 
  scope '/:path', constraints: { path: /.+/ } do
    get '/' => 'react#index', as: :react # react_path
  end
  RUBY
  end

  root 'home#index'

  %w( 404 422 500 ).each do |code|
    get code, :to => "errors#show", :code => code
  end
end
