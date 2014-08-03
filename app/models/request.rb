require 'open-uri'
require 'json'
require 'pry'

class Request < ActiveRecord::Base
  has_many :request_theaters
  has_many :theaters, through: :request_theaters
  def ip=(ip)
    @ip = ip
  end

  def ip
    @ip
  end

  def geocode()
    if self.query_address.strip == ""
      self.formatted_address = Geocoder::address(ip)
      self.latitude, self.longitude = Geocoder::coordinates(ip)
    else
      address = self.query_address.gsub(" ","+")
      url = "http://maps.google.com/maps/api/geocode/json?address=#{address}&sensor=false"
      results = JSON.load(open(url))["results"][0]

      self.formatted_address = results["formatted_address"]
      self.latitude =  results["geometry"]["location"]["lat"]
      self.longitude = results["geometry"]["location"]["lng"]
    end
    #8km, ~5mi
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
        cinema.gmaps_address = theater["vicinity"].gsub(' ', '+') || self.query_address.gsub(" ","+")
        cinema.save
      end
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
    Movie.build_movies
    movies = call_TMS_API()
    movies.each do |movie|
      three_d = false
      if movie["title"].end_with?(" 3D")
        three_d = true
        movie["title"] = movie["title"][0...-3]
      end
      if this_movie = Movie.find_by(title: movie["title"])
        if !this_movie.description
          this_movie.description = movie["shortDescription"]
          this_movie.save
        end
               
        if !this_movie.showtimes.any? || (this_movie.showtimes.any? && this_movie.showtimes.last.time < Time.now)
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
            show.three_d = three_d
            show.save
          end
        end
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

  def top_five_theaters
    theaters = Theater.joins(:request_theaters).where(:request_theaters => {:request_id => self.id}).where("\"rating\" > 0").order(:rating => :desc)
  end

  def top_showtimes
    results = []
    top_five_theaters.each do |theater|
      top_theaters = {}
      theater.top_movie_showtimes.each do |showtime|
        top_theaters[:name] ||= showtime["name"]
        top_theaters[:id] ||= showtime["id"]
        top_theaters[:rating] ||= showtime["rating"]
        top_theaters[:movies] ||= []
        if top_theaters[:movies].any? {|hash| hash[:title] == showtime["title"] }
          i = top_theaters[:movies].index(top_theaters[:movies].find{|hash| hash[:title] == showtime["title"]})
          if top_theaters[:movies][i][:showtimes].count < 3
            top_theaters[:movies][i][:showtimes] << {time: showtime["time"], fandango_url: showtime["fandango_url"], three_d: showtime["three_d"]}
          end
        else
          top_theaters[:movies] << {:title => showtime["title"],
                                :tomatometer => showtime["tomatometer"],
                                :description => showtime["description"],
                                :showtimes => [{time: showtime["time"], fandango_url: showtime["fandango_url"], three_d: showtime["three_d"]}]}  
        end
      end
      results << top_theaters
    end
    results
  end

private
  def slugify(string)
    string.gsub(" ","+").gsub("'","%27").gsub(":","%3A")
  end

  def normalize(string)
    string.sub("RPX","").sub("UA ","United Artists").downcase.sub("cinemas","").sub("cinema","").gsub(" ","").sub("theatre","theater").sub("movietheater","").sub("&","").sub("stadium","").sub("\u200e","")
  end

end
