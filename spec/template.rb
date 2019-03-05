copy_file "spec/support/factory_bot.rb"
copy_file "spec/factories.rb"

inject_into_file 'spec/rails_helper.rb', after: /# Add additional\w+this point!/ do
  <<-RUBY
require 'support/factory_bot'
  RUBY
end
