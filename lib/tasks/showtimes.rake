namespace :showtimes do
  desc "Delete old showtimes"
  task clear: :environment do
    Showtime.where("time < ?", Time.zone.now).destroy_all
  end

end
