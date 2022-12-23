redis_url = if Rails.env.production?
              redis_url = Rails.application.credentials.dig(:production, :redis_url)
              "#{redis_url || ENV["REDIS_URL"]}/1"
            elsif Rails.env.test?
              "#{ENV.fetch("REDIS_URL") { "redis://localhost:6379" }}/1"
            else
              "redis://localhost:6379/1"
            end

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end

# if Rails.env.development?
#   require 'sidekiq/testing'
#   Sidekiq::Testing.inline!
# end

Sidekiq.default_job_options = { retry: 0, backtrace: true }

schedule_file = "config/schedule.yml"
if Rails.env.production? && File.exist?(schedule_file) && Sidekiq.server?
  Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
end