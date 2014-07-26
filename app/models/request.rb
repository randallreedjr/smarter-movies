require 'open-uri'
require 'json'
require 'pry'
class Request < ActiveRecord::Base
  has_many :request_theaters
  has_many :theaters, through: :request_theaters

  def geocode()
    self.latitude =  40.708815
    self.longitude = -74.0079341
    self.radius = 8000
  end

  def call_API()
    
    base_url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
    base_url += "?key=#{ENV['GOOGLE_API_KEY']}"
    base_url += "&location=#{self.latitude},#{self.longitude}"
    base_url += "&radius=#{self.radius}"
    base_url += "&types=movie_theater"
    base_url += "&opennow"
    binding.pry
    return JSON.load(open(base_url))["results"]
  end
end
