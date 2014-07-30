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
    if theaters["next_page_token"]
      theaters["results"] += call_google_API(theaters["next_page_token"])["results"]
    end
    theaters["results"].each do |theater|
      next if theater["rating"] == 0
      normalized_name = normalize(theater["name"])
      if !(cinema = Theater.find_by(normalized_name: normalized_name))
        cinema = Theater.create(name: theater["name"], 
                                rating: theater["rating"], 
                                normalized_name: normalized_name)
      end
      cinema.gmaps_address ||= theater["vicinity"].gsub(' ', '+') || self.query_address.gsub(" ","+")
      cinema.save
      request_theater = self.request_theaters.build(request_id: self.id, theater_id: cinema.id)
      request_theater.save
    end
  end

  def call_google_API(pagetoken = "")
    if pagetoken.blank?
      base_url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
      base_url += "?key=#{ENV['GOOGLE_API_KEY']}"
      base_url += "&location=#{latitude},#{longitude}"
      base_url += "&radius=#{radius}"
      base_url += "&types=movie_theater"
      base_url += "&opennow"
    else
      base_url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
      base_url += "?pagetoken=#{pagetoken}"
      base_url += "&key=#{ENV['GOOGLE_API_KEY']}"
    end
    return JSON.load(open(base_url))
  end

  def make_movies()
    movies = call_TMS_API()
    movies.each do |movie|
      this_movie = Movie.find_by(title: movie["title"])
      if !this_movie
        
        this_movie = Movie.create(title: movie["title"])
        this_movie.tomatometer = get_tomatometer(movie["title"], movie["releaseYear"])
        this_movie.description ||= movie["shortDescription"]
        this_movie.save
        
      end
      movie["showtimes"].each do |showtime|
        #theater = Theater.find_or_create_by(:name => showtime["theatre"]["name"])
        normalized_name = normalize(showtime["theatre"]["name"])
        if !(theater = Theater.find_by(normalized_name: normalized_name))
          theater = Theater.create(name: showtime["theatre"]["name"],
                                   normalized_name: normalized_name)
        end
        if !RequestTheater.find_by(request_id: self.id, theater_id: theater.id)
          request_theater = self.request_theaters.build(request_id: self.id, theater_id: theater.id)
          request_theater.save
        end

        show = Showtime.find_or_create_by(:movie_id => this_movie.id, 
                                              :time => showtime["dateTime"],
                                              :theater_id => theater.id)
        show.fandango_url = showtime["ticketURI"]
        # showtime = this_movie.showtimes.find_or_initialize_by(:fandango_url => showtime["ticketURI"], 
        #                                    :time => showtime["dateTime"],
        #                                    :theater_id => theater.id)
        show.save
        
      end
    end
  end

  def call_TMS_API()
    movie_url = "http://data.tmsapi.com/v1/movies/showings?"
    movie_url += "startDate=#{Date.today.strftime("%Y-%m-%d")}&numDays=1&"
    movie_url += "lat=#{latitude}&lng=#{longitude}&radius=#{radius/1000}&units=km&"
    movie_url += "api_key=#{ENV['TMS_API_KEY']}"
    
    return JSON.load(open(movie_url))
  end

  def get_tomatometer(movie_title, release_year)
    movie_title.sub!(": An IMAX 3D Experience","")
    ratings = call_RT_API(movie_title)
    
    if ratings["total"] == 0 || !ratings["movies"]
      return -1
    else
      ratings["movies"].each do |rating|
        if rating["title"] == movie_title && rating["year"] == release_year
          score = rating["ratings"]["critics_score"]
          return score == -1 ? rating["ratings"]["audience_score"] : rating["ratings"]["critics_score"]
        end
      end
    end
    
    return ratings["movies"][0]["ratings"]["critics_score"]
  end

  def call_RT_API(movie_title)
    url = "http://api.rottentomatoes.com/api/public/v1.0/movies.json"
    url += "?q=#{slugify(movie_title)}&page_limit=10&page=1"
    url += "&apikey=#{ENV['RT_API_KEY']}"
    url = URI.encode(url)
    return JSON.load(open(url))
  end

private
  def slugify(string)
    string.gsub(" ","+").gsub("'","%27").gsub(":","%3A")
  end

  def normalize(string)
    string.sub("RPX","").sub("UA ","United Artists").downcase.sub("cinemas","").sub("cinema","").gsub(" ","").sub("theatre","theater").sub("movietheater","").sub("&","").sub("stadium","").sub("\u200e","")
  end

end
