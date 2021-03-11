class HealthCheckController < ApplicationController
  def index
    render status: :ok, json: { status: 'OK' }
  end
end
