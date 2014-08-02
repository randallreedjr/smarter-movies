class RequestsController < ApplicationController
  def index

  end

  def new
    @request = Request.new
  end

  def show
    @request = Request.find(params[:id])
    @results = @request.top_showtimes.reject{|h| h == {}}
  end
  
  def create
    @request = Request.create(request_params)
    @request.ip = remote_ip
    @request.geocode()
    @request.save()
    @request.make_theaters()
    if (@request.theaters.select do |theater|
      theater.movies.count > 3 && theater.showtimes.count > 6
    end).count <= 5
      @request.make_movies()
    end
    redirect_to request_path(@request)
  end

  private
  def request_params
    params.require(:request).permit(:query_address)
  end

  def remote_ip
    if request.remote_ip == '127.0.0.1'
      # Hard coded remote address
      '108.41.22.45'
    else
      request.remote_ip
    end
  end

end
