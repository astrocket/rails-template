gsub_file "config/environments/development.rb", "config.cache_store = :memory_store", <<-'RUBY'
config.cache_store = :redis_cache_store, {
      url: "redis://localhost:6379/2",
      pool_size: 5, # https://guides.rubyonrails.org/caching_with_rails.html#connection-pool-options
      pool_timeout: 3,
      connect_timeout: 10, # Defaults to 20 seconds
      read_timeout: 1, # Defaults to 1 second
      write_timeout: 1, # Defaults to 1 second
      reconnect_attempts: 3, # Defaults to 0
      reconnect_delay: 0.1,
      reconnect_delay_max: 0.2,
      error_handler: ->(method:, returning:, exception:) {
        Sentry.capture_exception exception, level: "warning",
                                 tags: {method: method, returning: returning}
      }
    }
RUBY

insert_into_file "config/environments/development.rb", before: /^end/ do
  <<-'RUBY'
  config.kredis.connector = ->(config) { ConnectionPool::Wrapper.new(size: 5, timeout: 3) { Redis.new(config) } } # redis from shared.yml

  config.action_mailer.default_url_options = {host: "http://localhost:3000"}
  config.action_mailer.asset_host = 'http://localhost:3000'
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.perform_deliveries = true
  RUBY
end
