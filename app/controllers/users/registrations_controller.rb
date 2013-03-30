class Users::RegistrationsController < Devise::RegistrationsController
  before_filter :hide_cover_image

  def edit
    render :edit
  end

  def update
    @user = User.find(current_user.id)
    prev_unconfirmed_email = @user.unconfirmed_email if @user.respond_to?(:unconfirmed_email)

    @user.name          = params[:user][:name]
    @user.email         = params[:user][:email]
    @user.bio           = params[:user][:bio]
    @user.sfw_filter    = params[:user][:sfw_filter]
    @user.star_rating   = params[:user][:star_rating]
    @user.about         = params[:user][:about]
    @user.avatar        = params[:user][:avatar] unless params[:user][:avatar].blank?
    @user.cover_image   = params[:user][:cover_image] unless params[:user][:cover_image].blank?

    if not params[:user][:password].blank?
      @user.password              = params[:user][:password]
      @user.password_confirmation = params[:user][:password_confirmation]
    end
    
    if @user.save
      if is_navigational_format?
        flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
          :update_needs_confirmation : :updated
        set_flash_message :notice, flash_key
      end
      sign_in resource_name, resource, :bypass => true
      respond_with resource, :location => after_update_path_for(resource)
    else
      clean_up_passwords resource
      respond_with resource
    end
  end
  
  def after_update_path_for(resource)
    "/dashboard"
  end
end
