class ListsController < ApplicationController
  before_action :logged_in_user
  before_action :check_ownership, only: [:destroy, :create]

  def show
    @user = User.find(params[:user_id])
    @list = @user.lists.find(params[:id])
    @listusers = @list.listusers.paginate(page: params[:page])
  end

  def index
    @user = User.find(params[:user_id])
    @lists = @user.lists
  end

  def new
    @user = current_user
    @list = List.new
  end

  def create
    list = current_user.lists.new(list_params)
    if list && list.save
      flash[:success] = "New List '#{list.name}' created!"
      redirect_to user_lists_url(current_user.id)
    else
      flash[:danger] = "We're sorry. There was a problem creating your list. Please try again"
      redirect_to list_new_url(current_user.id)
    end
  end

  def destroy
    list = List.find( list_user_params[:list_id] )
    flash[:success] = "List '#{list.name}' was deleted!"
    list.destroy
    redirect_to user_lists_url( list_user_params[:user_id] )
  end

  private
    def list_params
      params.require(:list).permit(:name)
    end

    def list_user_params
      params.permit(:user_id, :list_id)
    end

    def check_ownership
      unless current_user == User.find( params[:user_id] )
        flash[:danger] = "We're sorry. There was a problem creating your list. Please try again"
        redirect_to user_lists_url(current_user)
      end
    end
end
