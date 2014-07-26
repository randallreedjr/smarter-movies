class Theater < ActiveRecord::Base
  has_many :theater_requests
  has_many :requests, through: :theater_requests
  has_many :showtimes
  has_many :movies, through: :showtimes
end
