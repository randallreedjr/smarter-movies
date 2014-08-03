class Movie < ActiveRecord::Base
  has_many :showtimes
  has_many :theaters, through: :showtimes

  def fresh?
    tomatometer >= 60
  end

  def self.build_movies
    if !any? || last.created_at < Chronic.parse('last thursday')
      Movie.destroy_all
      movies = []
      3.times do |i|
        movies.concat currently_playing_RT_API(i+1)["movies"]
      end
      movies.each do |movie|
        this_movie = Movie.new(title: movie["title"])
        this_movie.tomatometer = movie["ratings"]["critics_score"]
        this_movie.save
      end
    end
  end

  def self.currently_playing_RT_API(page)
    url = "http://api.rottentomatoes.com/api/public/v1.0/lists/movies/in_theaters.json?apikey=#{ENV['RT_API_KEY']}&page_limit=50&page=#{page}"
    JSON.load(open(url))
  end

end
