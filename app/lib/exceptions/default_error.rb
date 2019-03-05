module Exceptions
  class DefaultError < StandardError
    attr_reader :message

    def initialize(msg = "알 수 없는 에러가 발생했습니다.")
      @message = msg
      Telegram.send(@message)
    end
  end
end
