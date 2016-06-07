class StaticPagesController < ApplicationController
  def home
    # remember: possible bug. Only define @micropost if current_user not nil(user logged in)
    if logged_in?
      @micropost  = current_user.microposts.build
      @feed_items = current_user.feed.paginate(page: params[:page])
    end
  end

  def help
  end

  def about
  end

  def contact
  end
end
