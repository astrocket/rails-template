class HttpPostJob < ApplicationJob
  queue_as :default
  include BotHelper

  def perform(url, options = {})
    post(url, options)
  end
end
