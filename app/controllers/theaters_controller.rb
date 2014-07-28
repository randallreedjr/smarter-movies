class TheatersController < ApplicationController
  def show
    @theater = Theater.find(params[:id])
    @gmaps_url = "https://www.google.com/maps/embed/v1/place?key=#{ENV['GOOGLE_API_KEY']}&q=#{@theater.gmaps_address}"
  end
end
