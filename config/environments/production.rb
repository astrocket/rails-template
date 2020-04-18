gsub_file 'config/environments/production.rb', 'config.assets.compile = false', 'config.assets.compile = true'

insert_into_file 'config/environments/production.rb', before: /^end/ do
  <<-'RUBY'
  config.exceptions_app = self.routes
  RUBY
end