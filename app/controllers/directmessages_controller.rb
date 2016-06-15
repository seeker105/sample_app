class DirectmessagesController < ApplicationController
  before_action :logged_in_user
  before_action :check_sender

  def new
    @user = User.find_by(id: params[:receiver_id])
    @message = Directmessage.new(sender_id: current_user.id, receiver_id: params[:receiver_id])
  end

  def create
    message = Directmessage.new( message_params )
    if message && message.save
      flash[:success] = "Your message to #{message_params[:receiver_id]} has been sent!"
      basic_redirect
    else
      action_fail
    end
  end

  def index
  end

  def show
  end

  def received
    @user = current_user
    @messages = Directmessage.where(receiver_id: current_user.id)
    @header = "Messages Received"
    # byebug
    render :index
  end

  def sent
    @user = current_user
    @messages = Directmessage.where(sender_id: current_user.id)
    @header = "Messages Sent"
    render :index
  end

  private
    def check_sender
      unless User.find_by(id: params[:sender_id]) == current_user
        action_fail
      end
    end

    def message_params
      params.permit(:sender_id, :receiver_id, :content)
    end
end
