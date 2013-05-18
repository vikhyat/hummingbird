class UsersController < ApplicationController
  before_filter :hide_cover_image

  def index
    authenticate_user!

    @status = {
      recommendations_up_to_date: current_user.recommendations_up_to_date,
      import_staging_completed: current_user.staged_import && current_user.staged_import.data[:complete]
    }
    
    respond_to do |format|
      format.html {
        flash.keep
        redirect_to '/'
      }
      format.json {
        render :json => @status
      }
    end
  end
  
  def show
    begin
      @user = User.find(params[:id])
    rescue
      # TEMPORARY
      # Support the slug URLs as well. Remove this once it becomes a performance
      # issue.
      @user = User.all.select {|x| x.name.parameterize == params[:id] }.first
      raise ActionController::RoutingError.new('Not Found') if @user.nil?
      redirect_to @user, :status => :moved_permanently
      return
    end

    redirect_to user_watchlist_path(@user)
    return

    @active_tab = :profile
    
    @latest_reviews = @user.reviews.order('created_at DESC').limit(2)

    @anime_history = {
      recently_watched: @user.watchlists.order('last_watched DESC').where("status <> 'Dropped' AND status <> 'Plan to Watch'").limit(3).map(&:anime),
      recently_completed: @user.watchlists.where(status: "Completed").order('last_watched DESC').limit(3).map(&:anime),
      plan_to_watch: @user.watchlists.where(status: "Plan to Watch").order('updated_at DESC').limit(3).map(&:anime)
    }
  end

  def followers
    @active_tab = :followers
    @user = User.find(params[:user_id])
    @results = @user.followers.page(params[:page]).per(20)
    render "followers_following", layout: "layouts/profile"
  end
  
  def following
    @active_tab = :following
    @user = User.find(params[:user_id])
    @results = @user.following.page(params[:page]).per(20)
    render "followers_following", layout: "layouts/profile"
  end

  def watchlist
    @active_tab = :library
    @user = User.find(params[:user_id])
    
    respond_to do |format|
      format.html { render "watchlist", layout: "profile" }
      format.json do
        status = Watchlist.status_parameter_to_status(params[:list])
        watchlists = []
        
        if status
          watchlists = @user.watchlists.accessible_by(current_ability).where(status: status).includes(:anime).page(params[:page]).per(50)
          # TODO simplify this sorting bit.
          if status == "Currently Watching"
            watchlists = watchlists.order('last_watched DESC')
          else
            watchlists = watchlists.order('created_at DESC')
          end
        end

        watchlists = watchlists.map {|x| x.to_hash current_user }
        
        render :json => watchlists
      end
    end
  end

  def follow
    authenticate_user!
    @user = User.find(params[:user_id])
    
    if @user != current_user
      if @user.followers.include? current_user
        @user.followers.destroy current_user
      else
        @user.followers.push current_user
        
        Action.create({
          user_id: current_user.id,
          action_type: "followed",
          followed_id: @user.id
        })
      end
    end
    
    respond_to do |format|
      format.html { redirect_to :back }
    end
  end

  def feed
    @active_tab = :feed
    @user = User.find(params[:user_id])
    @stories = Story.where(user_id: @user).page(params[:page]).per(20)
    render "feed", layout: "layouts/profile"
  end
  
  def reviews
    @user = User.find(params[:user_id])
    @active_tab = :reviews
    @reviews = @user.reviews.order("created_at DESC").page(params[:page]).per(15)
  end

  def forum_posts
    @user = User.find(params[:user_id])
    @posts = Forem::Post.where(user_id: @user).order('created_at DESC').page(params[:page]).per(Forem.per_page)
  end

  def update_cover_image
    @user = User.find(params[:user_id])
    authorize! :update, @user
    if params[:user][:cover_image]
      @user.cover_image = params[:user][:cover_image]
      flash[:success] = "Cover image updated successfully." if @user.save
    end
    redirect_to :back
  end

  def update_avatar
    @user = User.find(params[:user_id])
    authorize! :update, @user
    if params[:user][:avatar]
      @user.avatar = params[:user][:avatar]
      flash[:success] = "Avatar updated successfully." if @user.save
    end
    redirect_to :back
  end

  def disconnect_facebook
    authenticate_user!
    current_user.update_attributes(facebook_id: nil)
    redirect_to :back
  end
end
