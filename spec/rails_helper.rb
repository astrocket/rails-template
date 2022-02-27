insert_into_file "spec/rails_helper.rb", after: /require 'rspec\/rails'\n/ do
  <<~'RUBY'
    require 'support/factory_bot'
    require "sidekiq/testing"
    require "mock_redis"
  RUBY
end

insert_into_file "spec/rails_helper.rb", after: "RSpec.configure do |config|\n" do
  <<~'RUBY'
    config.use_transactional_fixtures = true
    config.include Devise::Test::IntegrationHelpers
    config.include ActiveSupport::Testing::TimeHelpers
    config.include ActiveJob::TestHelper
    config.before(:suite) do
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.clean_with(:truncation)
    end
    config.before(:all) do
      Sidekiq::Testing.fake!
    end
    config.before(:each) do
      Sidekiq::Worker.clear_all
      allow(Redis).to receive(:new) { MockRedis.new }
    end
  RUBY
end
