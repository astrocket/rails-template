class Api::ApiController < ActionController::API
  rescue_from Exceptions::DefaultError do |e|
    render json: {
        message: e.message,
        status: 400
    }
  end
end