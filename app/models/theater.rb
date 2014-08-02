class Theater < ActiveRecord::Base
  has_many :request_theaters
  has_many :requests, through: :request_theaters
  has_many :showtimes
  has_many :movies, through: :showtimes

  def top_movie_showtimes()
    current_time = Time.now.strftime("%Y-%m-%dT%H:%M:%S")
    sql = <<-SQL
    SELECT theaters.name, 
           movies.title, 
           movies.tomatometer, 
           movies.description,
           theaters.rating, 
           showtimes.time,
           showtimes.fandango_url
    FROM theaters
    JOIN
    (
      SELECT showtimes.theater_id, 
             movies.tomatometer 
      FROM showtimes
      JOIN movies 
      ON movies.id = showtimes.movie_id
      WHERE showtimes.theater_id = #{self.id}
      AND showtimes.time > '#{current_time}'
      GROUP BY showtimes.movie_id, 
               movies.tomatometer
      HAVING count(*) >= 2
      ORDER BY movies.tomatometer DESC
      LIMIT 1 OFFSET 2
    ) third_tomatometer
    ON theaters.id = third_tomatometer.theater_id
    JOIN showtimes 
    ON showtimes.theater_id = theaters.id
    JOIN movies
    ON movies.tomatometer >= third_tomatometer.tomatometer
    AND movies.id = showtimes.movie_id
    WHERE showtimes.time > '#{current_time}'
    ORDER BY movies.tomatometer DESC, 
             movies.title, 
             showtimes.time
SQL
    ActiveRecord::Base.connection.execute(sql)
  end



  # def top_three_movies
  #   # Movie.joins(:showtimes => :theater).
  #   #   where(:theaters => {:id => self.id}).
  #   #   order(:tomatometer => :desc).distinct.limit(3)

  #   movs_with_showtimes = movies.collect do |movie|
  #     movie unless movie.next_three_showtimes(self).empty?
  #   end.compact.uniq

  #   movs = movs_with_showtimes.sort_by(&:tomatometer).reverse

  #   movs = movs[0..2] if movs.size > 3
  #   return movs
  # end
end




