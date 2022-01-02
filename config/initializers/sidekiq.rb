redis_url = if Rails.env.production?
  ENV["REDIS_URL"] || Rails.application.credentials.dig(:production, :redis_url)
else
  "redis://localhost:6379/1"
end

Sidekiq.configure_server do |config|
  config.redis = {url: redis_url}
end

Sidekiq.configure_client do |config|
  config.redis = {url: redis_url}
end

# if Rails.env.development?
#   require 'sidekiq/testing'
#   Sidekiq::Testing.inline!
# end

Sidekiq.default_worker_options = {retry: 1}
