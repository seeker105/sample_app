class ListsController < ApplicationController
  before_action :logged_in_user



  def show
    @user = current_user
    @list = current_user.lists.find(params[:list_id])
    @listusers = @list.listusers.paginate(page: params[:page])
   # byebug
  end

  def index
    @lists = current_user.lists
    @user = current_user
  end



end
