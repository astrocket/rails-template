class SlackMessageJob < ApplicationJob
  queue_as :default

  def perform(msg, channel)
    client = Slack::Web::Client.new
    client.chat_postMessage(channel: channel, text: msg, as_user: true)
  end
end
