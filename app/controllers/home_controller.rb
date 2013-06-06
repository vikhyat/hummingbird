class HomeController < ApplicationController
  before_filter :hide_cover_image
  #caches_action :index, layout: false, :if => lambda { not user_signed_in? }

  def index
    if user_signed_in? and current_user.id == 1

      @forum_topics = Forem::Topic.by_most_recent_post.limit(10)
      
    elsif user_signed_in?

      @recent_anime_users = User.joins(:watchlists).where('watchlists.episodes_watched > 0').order('MAX(watchlists.last_watched) DESC').group('users.id').limit(8)
      @recent_anime = @recent_anime_users.map {|x| x.watchlists.where("EXISTS (SELECT 1 FROM anime WHERE anime.id = anime_id AND age_rating <> 'R18+')").order('updated_at DESC').limit(1).first }.sort_by {|x| x.last_watched || x.updated_at }.reverse
      @latest_reviews = Review.order('created_at DESC').limit(2)

      render :old_index

    else
      render :guest_index
    end
  end
  
  def dashboard
    authenticate_user!
    redirect_to user_path(current_user)
  end

  def privacy
  end
end
