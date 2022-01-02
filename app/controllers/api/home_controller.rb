module Api
  class HomeController < Api::ApiController
    # sample api
    def index
      render json: {
        hello: "#{Rails.version} (#{Rails.env})"
      }
    end
  end
end
