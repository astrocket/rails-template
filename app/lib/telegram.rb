class Telegram
  API_KEY = Rails.application.credentials.telegram_token
  LOG_CHAT = Rails.application.credentials.telegram_log_chat

  class << self
    def send(message, chat_id = LOG_CHAT)
      HttpPostJob.perform_later("https://api.telegram.org/bot#{API_KEY}/sendMessage", {
          body: {
              text: "[#{Rails.env.capitalize}]#{"\n"}#{message}",
              chat_id: chat_id
          }
      })
    end
  end
end
