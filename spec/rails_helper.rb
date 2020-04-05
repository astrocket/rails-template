insert_into_file 'spec/rails_helper.rb', after: /require 'rspec\/rails'\n/ do
  <<-'RUBY'
require 'support/factory_bot'
  RUBY
end