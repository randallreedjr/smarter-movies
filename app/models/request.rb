require 'open-uri'
require 'json'
class Request < ActiveRecord::Base
  has_many :request_theaters
  has_many :theaters, through: :request_theaters

  def initialize

  end

  def call_API()
    base_url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
    base_url += "?key=#{ENV['GOOGLE_API_KEY']}"
    base_url += "&location=40.708815,-74.0079341"
    base_url += "&radius=8000"
    base_url += "&types=movie_theater"
    base_url += "&opennow"

    return JSON.load(open(base_url))["results"]
  end
end
