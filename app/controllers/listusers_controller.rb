class ListusersController < ApplicationController
  before_action :logged_in_user
  before_action :check_valid_user_list


  def add
    new_relation = Listuser.new(list_id: listuser_params[:list_id], selected_user_id: listuser_params[:user_id])
    if new_relation && new_relation.save
      redirect_to list_show_url(user_id: current_user.id, id: listuser_params[:list_id])
    else
      flash[:danger] = "We're sorry, the users was not correctly added to your list. Please try again"
      flash[:danger] = "A user cannot appear twice in the same list" unless new_relation.valid?
      request.referrer ? (redirect_to request.referrer) : (redirect_to root_url)
    end
  end

  def delete
    listuser = Listuser.find(list_params[:listuser_id])
    list = listuser.list
    if list.owner == current_user
      flash[:success] = "User #{listuser.selected_user.name} has been removed from #{list.name}"
      listuser.destroy
    else
      flash[:danger] = "We're sorry, the users was not correctly added to your list. Please try again"
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

    def check_valid_user_list
      unless current_user.lists.find_by(id: listuser_params[:list_id] )
        request.referrer ? (redirect_to request.referrer) : (redirect_to root_url)
      end
    end


end
