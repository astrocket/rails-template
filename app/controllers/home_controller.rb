class HomeController < ApplicationController
  def index
  end

  # for k8s health check
  def health_check
    render json: {
      rails_version: Rails.version,
      deploy_version: ENV.fetch("DEPLOY_VERSION")
    }, status: :ok
  end
end
