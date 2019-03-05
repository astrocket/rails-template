insert_into_file 'config/routes.rb', before: /^end/ do
  <<-'RUBY'
   require 'sidekiq/web'
   mount Sidekiq::Web => '/sidekiq'
  
   namespace :api do
      
   end
  RUBY
end