namespace :movies do
  desc "Load movies from Rotten Tomatoes"
  task load: :environment do
    Movie.build_movies
  end

end
