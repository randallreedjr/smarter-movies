class Theater < ActiveRecord::Base
  has_many :request_theaters
  has_many :requests, through: :request_theaters
  has_many :showtimes
  has_many :movies, through: :showtimes

  def top_movie_showtimes()
    current_time = Time.now.strftime("%Y-%m-%dT%H:%M:%S")
    sql = <<-SQL
    SELECT theaters.name, 
           theaters.id,
           theaters.rating, 
           movies.title, 
           movies.tomatometer, 
           movies.description,
           showtimes.time,
           showtimes.fandango_url,
           showtimes.three_d
    FROM theaters
    JOIN
    (
      SELECT showtimes.theater_id, 
             movies.tomatometer 
      FROM showtimes
      JOIN movies 
      ON movies.id = showtimes.movie_id
      WHERE showtimes.theater_id = '#{self.id}'
      AND showtimes.time > '#{current_time}'
      GROUP BY showtimes.theater_id, 
               movies.tomatometer
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
end




