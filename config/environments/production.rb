gsub_file "config/environments/production.rb", "config.assets.compile = false", "config.assets.compile = true"

insert_into_file "config/environments/production.rb", before: /^end/ do
  <<-'RUBY'
  config.exceptions_app = self.routes

  config.cache_store = :redis_cache_store, {
    url: "#{Rails.application.credentials.dig(:production, :redis_url) || ENV["REDIS_URL"]}/2",
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

  config.kredis.connector = ->(config) { ConnectionPool::Wrapper.new(size: 5, timeout: 3) { Redis.new(config) } } # redis from shared.yml
  RUBY
end
