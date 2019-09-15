module Api
  class HomeController < Api::ApiController
    def index
      render json: {
          hello: "Hello World from Rails"
      }
    end
  end
end