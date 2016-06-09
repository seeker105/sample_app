class SessionsController < ApplicationController
  before_action :logged_in_user, only: :request_github_access
  def new
  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user && @user.authenticate(params[:session][:password])
      if @user.activated?
        log_in @user
        params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
        redirect_back_or @user
      else
        message  = "Account not activated. "
        message += "Check your email for the activation link."
        flash[:warning] = message
        redirect_to root_url
      end
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  def request_github_access
    scope = "user repo admin:org notifications gist"
    state = session['state'] = SecureRandom.urlsafe_base64
    redirect_to "https://github.com/login/oauth/authorize?client_id=#{ENV['github_key']}&scope=#{scope}&state=#{state}"
  end

  def exchange_token
    if params['state'] == session['state']
      exchange_connection = Faraday.new(url: "https://github.com/login/oauth/access_token")
      response = exchange_connection.post do |req|
        req.headers['Accept'] = 'application/json'
        req.params['client_id'] = ENV['github_key']
        req.params['client_secret'] = ENV['github_secret']
        req.params['code'] = params['code']
        req.params['state'] = session['state']
      end
      access_token = JSON.parse(response.body)['access_token'] if response.body

      github_login_fail unless access_token


      current_user.update_attribute(:github_access_token, access_token)
      flash[:success] = "You are now connected to GitHub!" if github_connected?
      redirect_to root_url
    end
  end

end
