class Movie < ActiveRecord::Base
  has_many :showtimes
  has_many :theaters, through: :showtimes

  # <% movie.showtimes.each do |showtime| %>
  #               <% next if showtime.theater != theater %>
  #               <% if showtime.upcoming? %>
  #                 <li class="list-group-item">
  #                   <%= showtime.readable_time %>
  #                   <% if showtime.fandango_url %>
  #                     - <%= link_to "Fandango", showtime.fandango_url%>
  #                   <% end %>
  #                 </li>
  #               <% end %>
  #             <% end %>

  def next_five_showtimes(cinema)
    st = showtimes.collect do |showtime|
      next if showtime.theater != cinema
      showtime if showtime.upcoming?
    end.compact

    st = st[0..4] if st.size > 5
    return st
  end

end
