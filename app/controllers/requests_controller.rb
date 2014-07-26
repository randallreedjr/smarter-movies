class RequestsController < ApplicationController
  def index
    @request = Request.new()
    @results = @request.call_API()
  end

  def new
    @request = Request.new
  end

  def show
    @request = Request.find(params[:id])
    @theaters = Theater.joins("INNER JOIN \"request_theaters\" ON \"request_theaters\".\"theater_id\" = \"theaters\".\"id\"")
                  .where("\"request_theaters\".\"request_id\" = ?", @request.id)
                  .order("\"theaters\".\"rating\" DESC").limit(5)
  end

  def create
    @request = Request.create(request_params)
    @request.geocode()
    @request.save()
    @request.make_theaters()

    redirect_to request_path(@request)
  end

  private
  def request_params
    params.require(:request).permit(:query_address)
  end

end
