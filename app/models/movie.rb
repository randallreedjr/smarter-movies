class Movie < ActiveRecord::Base
  has_many :showtimes
  has_many :theaters, through: :showtimes

  def next_three_showtimes(cinema)
    st = showtimes.collect do |showtime|
      next if showtime.theater != cinema
      showtime if showtime.upcoming?
    end.compact

    st = st[0..2] if st.size > 3
    return st
  end

  def fresh?
    tomatometer >= 60
  end

end
