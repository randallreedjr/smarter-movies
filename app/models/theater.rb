class Theater < ActiveRecord::Base
  has_many :theater_requests
  has_many :requests, through: :theater_requests
  has_many :showtimes
  has_many :movies, through: :showtimes

  def top_three_movies
    # Movie.joins(:showtimes => :theater).
    #   where(:theaters => {:id => self.id}).
    #   order(:tomatometer => :desc).distinct.limit(3)

    movs_with_showtimes = movies.collect do |movie|
      movie unless movie.next_three_showtimes(self).empty?
    end.compact.uniq

    movs = movs_with_showtimes.sort_by(&:tomatometer).reverse

    movs = movs[0..2] if movs.size > 3
    return movs
  end
end




