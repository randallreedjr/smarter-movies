require 'open-uri'
require 'json'
require 'pry'

# GOOGLE_API_KEY= "AIzaSyDOSbxoMOpXF6Ggi3FKc_oImDD5frfDSB8"

# base_url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
# #base_url += "?key=#{ENV['GOOGLE_API_KEY']}"
# base_url += "?key=#{GOOGLE_API_KEY}"
# base_url += "&location=40.708815,-74.0079341"
# base_url += "&radius=8000"
# base_url += "&types=movie_theater"
# base_url += "&opennow"



# theaters = JSON.load(open(base_url))["results"]

# puts "#{theaters.count} results:"
# theaters.each_with_index do |theater, index|
#   puts "#{index + 1}. #{theater["name"]} (#{theater["rating"]})"
# end

# movie_url = "http://data.tmsapi.com/v1/movies/showings?startDate=2014-07-21&numDays=1&lat=40.708815&lng=-74.0079341&radius=8&units=km&api_key=2frtr32jatbpmc9sa677mfvb"
# movies = JSON.load(open(movie_url))

# movie_theaters = movies[1]["showtimes"].collect do |showing|
#   showing["theatre"]["name"]
# end
# #binding.pry
# puts "#{movies[1]["title"]} playing at:"
# print movie_theaters.uniq.inspect

address = "11 Broadway"
address.gsub!(" ","+")
base_url = "http://maps.google.com/maps/api/geocode/json?address=#{address}&sensor=false"
results = JSON.load(open(base_url))["results"]
puts results






