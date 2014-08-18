namespace :movies do
  desc "TODO"
  task load: :environment do
    Movie.build_movies
  end

end
