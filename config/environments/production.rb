insert_into_file 'config/environments/production.rb', before: /^end/ do
  <<-'RUBY'
  config.exceptions_app = self.routes
  RUBY
end