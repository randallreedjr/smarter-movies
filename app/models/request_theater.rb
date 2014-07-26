class RequestTheater < ActiveRecord::Base
  belongs_to :request
  belongs_to :theater
end
