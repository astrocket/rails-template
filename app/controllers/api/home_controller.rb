module Api
  class HomeController < Api::ApiController
    def index
      render json: {
          hello: "#{Rails.version} (#{Rails.env})"
      }
    end
  end
end