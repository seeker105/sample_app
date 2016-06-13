class ListsController < ApplicationController
  before_action :logged_in_user
  before_action :check_authorization, only: :destroy

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

  def destroy
    list = List.find( list_user_params[:list_id] )
    flash[:success] = "List '#{list.name}' was deleted!"
    list.destroy
    redirect_to lists_url( list_user_params[:user_id] )
  end

  private
    def list_params
      params.require(:list).permit(:name)
    end

    def list_user_params
      params.permit(:user_id, :list_id)
    end

    def check_authorization
      unless current_user == User.find( list_user_params[:user_id] )
        raise ActionController::RoutingError.new('Not Found')
      end
    end
end
