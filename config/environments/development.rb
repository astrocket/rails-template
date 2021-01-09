insert_into_file 'config/environments/development.rb', before: /^end/ do
  <<-'RUBY'
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.perform_deliveries = true
  RUBY
end