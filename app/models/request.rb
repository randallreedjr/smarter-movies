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

  def make_theaters()
    theaters = call_google_API()
    theaters.each do |theater|
      theater = Theater.find_or_create_by(name: theater["name"], rating: theater["rating"])
      theater.save
      request_theater = self.request_theaters.build(request_id: self.id, theater_id: theater.id)
      request_theater.save
      #theater.get_info()
    end
  end

  def call_google_API()
    
    base_url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
    base_url += "?key=#{ENV['GOOGLE_API_KEY']}"
    base_url += "&location=#{latitude},#{longitude}"
    base_url += "&radius=#{radius}"
    base_url += "&types=movie_theater"
    base_url += "&opennow"
    
    return JSON.load(open(base_url))["results"]
  end

  def make_movies()
    movies = call_TMS_API()
    movies.each do |movie|
      this_movie = Movie.find_or_create_by(title: movie["title"])
      this_movie.description ||= movie["shortDescription"]
      this_movie.save
      movie["showtimes"].each do |showtime|
        #binding.pry unless showtime["theatre"]["name"] == "Regal Battery Park Stadium 11"
        theater = Theater.find_or_create_by(:name => showtime["theatre"]["name"])

        #binding.pry
        #if theater
        request_theater = self.request_theaters.build(request_id: self.id, theater_id: theater.id)
        request_theater.save
        showtime = this_movie.showtimes.build(:url => showtime["ticketURI"], 
                                           :time => showtime["dateTime"],
                                           :theater_id => theater.id)
        showtime.save
        #end
      end
    end
  end

  def call_TMS_API()

    movie_url = "http://data.tmsapi.com/v1/movies/showings?"
    movie_url += "startDate=#{Date.today.strftime("%Y-%m-%d")}&numDays=1&"
    movie_url += "lat=#{latitude}&lng=#{longitude}&radius=#{radius/1000}&units=km&"
    movie_url += "api_key=#{ENV['TMS_API_KEY']}"
    
    return JSON.load(open(movie_url))

# movie_theaters = movies[1]["showtimes"].collect do |showing|
#   showing["theatre"]["name"]
# end



  end
end
