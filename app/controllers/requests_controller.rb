class RequestsController < ApplicationController
  def index
    @request = Request.new()
    @results = @request.call_API()
  end
end
