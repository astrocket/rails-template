class HomeController < ApplicationController
  def index
  end

  # for k8s health check
  def health_check
    render json: {
        health_check: "#{Rails.version} (#{Rails.env})"
    }
  end
end
