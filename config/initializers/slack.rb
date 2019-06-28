Slack.configure do |config|
  config.token = Rails.application.credentials.(&:slack_api_token)
end