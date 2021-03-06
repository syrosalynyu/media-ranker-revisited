class UsersController < ApplicationController
  skip_before_action :required_login, except: [:index, :show]

  def index
    @users = User.all
  end

  def show
    @user = User.find_by(id: params[:id])
    render_404 unless @user
  end

  def login_form
  end

  def login
    auth_hash = request.env["omniauth.auth"]

    user = User.find_by(uid: auth_hash["uid"], provider: params[:provider])

    if user # existing user
      flash[:status] = :success
      flash[:result_text] = "Welcome back, #{user.username}!"
    else # new user (will have to create the user record)
      user = User.build_from_github(auth_hash)
      if user.save
        flash[:status] = :success
        flash[:result_text] = "Welcome, #{user.username}!"
      else
        flash[:status] = :failure
        flash[:result_text] = "Couldn't create a user account"
        flash[:messages] = user.errors.messages
        return redirect_to root_path
      end
    end
    session[:user_id] = user.id
    redirect_to root_path
    # username = params[:username]
    # if username and user = User.find_by(username: username)
    #   session[:user_id] = user.id
    #   flash[:status] = :success
    #   flash[:result_text] = "Successfully logged in as existing user #{user.username}"
    # else
    #   user = User.new(username: username)
    #   if user.save
    #     session[:user_id] = user.id
    #     flash[:status] = :success
    #     flash[:result_text] = "Successfully created new user #{user.username} with ID #{user.id}"
    #   else
    #     flash.now[:status] = :failure
    #     flash.now[:result_text] = "Could not log in"
    #     flash.now[:messages] = user.errors.messages
    #     render "login_form", status: :bad_request
    #     return
    #   end
    # end
    # redirect_to root_path
  end

  def logout
    session[:user_id] = nil
    flash[:result_text] = "Successfully logged out"
    redirect_to root_path
  end
end
