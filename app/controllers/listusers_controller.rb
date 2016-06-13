class ListusersController < ApplicationController
  before_action :logged_in_user

  def add
    # byebug
    if current_user.lists.find( listuser_params[:list_id] )
      new_relation = Listuser.new(list_id: listuser_params[:list_id], selected_user_id: listuser_params[:user_id])
    end
    if new_relation && new_relation.save
      redirect_to list_show_url(user_id: current_user.id, id: listuser_params[:list_id])
    else
      flash[:error] = "We're sorry, the users was not correctly added to your list. Please try again"
      redirect_to request.referrer
    end
  end

  def delete
    listuser = Listuser.find(list_params[:listuser_id])
    list = listuser.list
    if list.owner == current_user
      flash[:success] = "User #{listuser.selected_user.name} has been removed from #{list.name}"
      listuser.destroy
    else
      flash[:error] = "We're sorry, the users was not correctly added to your list. Please try again"
    end
    redirect_to request.referrer
  end

  private
    def listuser_params
      params.permit(:list_id, :user_id)
    end

    def list_params
      params.permit(:listuser_id)
    end

end
