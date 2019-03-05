insert_into_file 'spec/rails_helper.rb', after: /# Add additional\w+this point!\n/ do
  <<-'RUBY'
require 'support/factory_bot'
  RUBY
end