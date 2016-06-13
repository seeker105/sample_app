class ListsController < ApplicationController
  before_action :logged_in_user



  def show
    @user = current_user
    @list = current_user.lists.find(params[:id])
    @listusers = @list.listusers.paginate(page: params[:page])
    # byebug
  end

  def index
    @lists = current_user.lists
    @user = current_user
  end

  def new
    @user = current_user
    @list = List.new
  end

  def create
    list = current_user.lists.new(list_params)
    if list && list.save
      flash[:success] = "New List '#{list.name}' created!"
      redirect_to lists_url(current_user.id)
    else
      flash[:warning] = "We're sorry. There was a problem creating your list. Please try again"
      redirect_to list_new_url(current_user.id)
    end
  end


  private
    def list_params
      params.require(:list).permit(:name)
    end

end
