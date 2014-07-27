class Theater < ActiveRecord::Base
  has_many :theater_requests
  has_many :requests, through: :theater_requests
  has_many :showtimes
  has_many :movies, through: :showtimes

  def top_movies
    Movie.joins(:showtimes => :theater).
      where(:theaters => {:id => self.id}).
      order(:tomatometer => :desc).distinct.limit(5)
  end
end




