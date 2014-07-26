class RequestsController < ApplicationController
  def index

  end

  def new
    @request = Request.new
  end

  def show
    @request = Request.find(params[:id])
    @theaters = Theater.joins("INNER JOIN \"request_theaters\" ON \"request_theaters\".\"theater_id\" = \"theaters\".\"id\"")
                  .joins("INNER JOIN \"showtimes\" ON \"showtimes\".\"theater_id\" = \"theaters\".\"id\"")
                  .where("\"request_theaters\".\"request_id\" = ?", @request.id)
                  .order("\"theaters\".\"rating\" DESC").limit(5).distinct()
  end

  def create
    @request = Request.create(request_params)
    @request.geocode()
    @request.save()
    @request.make_theaters()
    @request.make_movies()
    redirect_to request_path(@request)
  end

  private
  def request_params
    params.require(:request).permit(:query_address)
  end

end
