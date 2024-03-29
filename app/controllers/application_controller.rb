class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method def remote_ip
    if request.remote_ip == '127.0.0.1'
      # Hard coded remote address
      '108.41.22.45'
    else
      request.remote_ip
    end
  end
end
