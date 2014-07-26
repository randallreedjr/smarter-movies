require 'open-uri'
require 'json'
require 'pry'
class Request < ActiveRecord::Base
  has_many :request_theaters
  has_many :theaters, through: :request_theaters

  def geocode()

    address = self.query_address.gsub(" ","+")
    url = "http://maps.google.com/maps/api/geocode/json?address=#{address}&sensor=false"
    results = JSON.load(open(url))["results"][0]

    self.formatted_address = results["formatted_address"]
    self.latitude =  results["geometry"]["location"]["lat"]
    self.longitude = results["geometry"]["location"]["lng"]
    self.radius = 8000
  end

  def call_API()
    
    base_url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
    base_url += "?key=#{ENV['GOOGLE_API_KEY']}"
    base_url += "&location=#{self.latitude},#{self.longitude}"
    base_url += "&radius=#{self.radius}"
    base_url += "&types=movie_theater"
    base_url += "&opennow"
    
    return JSON.load(open(base_url))["results"]
  end
end
