class SlackService
  class << self
    CHANNELS = {
        github: "#github_noti",
        error: Rails.env.production? ? "#production_error" : "#development",
        log: Rails.env.production? ? "#production_log" : "#development",
    }

    def send_message(title, msg, channel = :log)
      title = "🤔 " + title if channel == :error
      title = "🔥 " + title if channel == :log
      SlackMessageJob.perform_later("*#{title}*#{"\n"}```#{msg}```", CHANNELS[channel])
    end

    def send_exception(e, title = e.message, prepend = nil)
      title = "🤔 " + title
      SlackMessageJob.perform_later("*#{title}*#{"\n"}```#{prepend}#{"\n"}#{e.backtrace.first(20).join("\n")}```", CHANNELS[:error])
    end

    def upload_file(file, channel = :log)
      # client.files_upload(
      #     channels: '#general',
      #     as_user: true,
      #     file: Faraday::UploadIO.new('/path/to/avatar.jpg', 'image/jpeg'),
      #     title: 'My Avatar',
      #     filename: 'avatar.jpg',
      #     initial_comment: 'Attached a selfie.'
      # )
    end
  end
end