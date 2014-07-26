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
    @results = @request.call_API()
  end

  def create
    @request = Request.create(request_params)
    @request.geocode()
    @request.save()
    redirect_to request_path(@request)
  end

  private
  def request_params
    params.require(:request).permit(:query_address)
  end

end
