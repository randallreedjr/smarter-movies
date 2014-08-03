class TheatersController < ApplicationController
  def show
    @theater = Theater.find(params[:id])
  end
end
