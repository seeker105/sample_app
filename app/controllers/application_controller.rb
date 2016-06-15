class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper

  private
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end

    def check_authorization
      unless current_user == User.find( params[:user_id] )
        raise ActionController::RoutingError.new('Not Found')
      end
    end

    def action_fail(message = "")
      flash[:danger] = "We're sorry. There was a problem with your request." + message
    end

    def basic_redirect
      request.referrer ? (redirect_to request.referrer): (redirect_to root_url)
    end
end
