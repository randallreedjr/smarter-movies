class Request < ActiveRecord::Base
  has_many :request_theaters
  has_many :theaters, through: :request_theaters
end
