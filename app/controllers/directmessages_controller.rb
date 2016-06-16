class DirectmessagesController < ApplicationController
  before_action :logged_in_user
  before_action :check_sender, only: :create
  before_action :check_authorization, only: :show

  def new
    @user = User.find_by(id: params[:receiver_id])
    @directmessage = Directmessage.new(sender_id: current_user.id, receiver_id: params[:receiver_id])
  end

  def create
    message = Directmessage.new( message_params )
    if message && message.save
      flash[:success] = "Your message to #{message.receiver.name} has been sent!"
      redirect_to user_url(message.receiver)
    else
      action_fail
    end
  end

  def show
    # byebug
    @message = Directmessage.find_by(id: params[:message_id])
    @user = current_user
    if @message.sender == current_user
      @other_label = "Sent to:"
      @other_user = @message.receiver
    else
      @other_label = "Sent from:"
      @other_user = @message.sender
    end
  end

  def received
    @user = current_user
    @messages = Directmessage.where(receiver_id: current_user.id)
    @header = "Messages Received"
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
      params.require(:directmessage).permit(:sender_id, :receiver_id, :content)
    end
end
