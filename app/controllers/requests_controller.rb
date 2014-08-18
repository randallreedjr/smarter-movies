class RequestsController < ApplicationController
  def index

  end

  def new
    @request = Request.new
  end

  def show
    @request = Request.find(params[:id])
    @results = @request.top_showtimes.reject{|h| h == {}}[0..4]
  end
  
  def create
    @request = Request.new(request_params)
    @request.ip = remote_ip
    @request.geocode
    
    today = Time.now.strftime('%Y-%m-%d')
    matching_requests = Request.where("zip_code = ? AND created_at > ?", @request.zip_code,today)
    if !@request = matching_requests.first
      @request.save
      @request.make_theaters
    end
    
    current_time = Time.now.strftime("%Y-%m-%dT%H:%M:%S")
    theaters_with_showtimes = @request.theaters.select do |theater|
      theater.movies.distinct.count > 3 && theater.showtimes.where("time > ?", current_time).count >= 6
    end

    if theaters_with_showtimes.count <= 5
      @request.make_movies()
    end
    redirect_to request_path(@request)
  end

  private
  def request_params
    params.require(:request).permit(:query_address)
  end

end
