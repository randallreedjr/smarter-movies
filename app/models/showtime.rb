class Showtime < ActiveRecord::Base
  belongs_to :theater
  belongs_to :movie

  def readable_time
    time.split('T').join(' ')
  end

  def to_datetime
    Time.parse(readable_time) #=> "2014-07-27 10:30:00 -0400"
  end

  def upcoming?
    to_datetime > Time.now
  end

end
