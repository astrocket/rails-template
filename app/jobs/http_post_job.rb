class HttpPostJob < ApplicationJob
  queue_as :default
  include HttpHelper

  def perform(url, options = {})
    post(url, options)
  end
end
