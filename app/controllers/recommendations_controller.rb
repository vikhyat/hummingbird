class RecommendationsController < ApplicationController
  before_filter :authenticate_user!

  def update_recommendations_if_needed(needed=false)
    if current_user.last_library_update.nil?
      current_user.update_column :last_library_update, Time.now
    end

    if (needed or current_user.last_recommendations_update.nil? or current_user.last_library_update > current_user.last_recommendations_update)
      current_user.update_column :recommendations_up_to_date, false
      RecommendingWorker.perform_async(current_user.id)
    end
  end
  
  def index
    @hide_cover_image = true
    
    update_recommendations_if_needed
    
    # Uncomment for synchronous recommendations.
    # RecommendingWorker.new.perform(current_user.id)
    
    # Load recommended anime.
    r = current_user.recommendation
    @status_categories = ["currently_watching", "plan_to_watch", "completed"]
    @recommendations = {}
    @status_categories.each do |cat|
      @recommendations[cat] = r ? JSON.parse(r.recommendations["by_status"])[cat].map {|x| Anime.find(x) } : []
    end

    @neon_alley = r ? JSON.parse(r.recommendations["by_service"])["neon_alley"].map {|x| Anime.find(x) } : []
    
    # View convenience variables. Move to translations later.
    @word_before = {
      "currently_watching" => "you're",
      "plan_to_watch" => "you",
      "completed" => "you've"
    }
  end

  def not_interested
    anime = Anime.find params[:anime]
    unless current_user.not_interested_anime.include? anime
      current_user.not_interested_anime.push anime
      mixpanel.track "Recommendations: Not Interested", {email: current_user.email, anime: anime.slug} if Rails.env.production?
      current_user.update_column :last_library_update, Time.now
    end
    update_recommendations_if_needed true
    render :json => true
  end

  def plan_to_watch
    anime = Anime.find params[:anime]
    watchlist = Watchlist.find_or_create_by_anime_id_and_user_id(anime.id, current_user.id)
    watchlist.status = "Plan to Watch"
    watchlist.save
    mixpanel.track "Recommendations: Plan to Watch", {email: current_user.email, anime: anime.slug} if Rails.env.production?
    update_recommendations_if_needed true
    render :json => true
  end
end
