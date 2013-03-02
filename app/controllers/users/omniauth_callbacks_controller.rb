class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    @user = User.find_for_facebook_oauth(request.env["omniauth.auth"], current_user)
    
    if @user.persisted?
      flash[:notice] = "Successfully signed in using Facebook."
    else
      flash[:notice] = "Successfully created a new account using Facebook."
    end

    sign_in_and_redirect @user, :event => :authentication
  end
end
