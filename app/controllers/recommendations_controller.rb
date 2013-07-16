class RecommendationsController < ApplicationController
  before_filter :authenticate_user!

  def update_recommendations_if_needed
    if current_user.last_library_update.nil?
      current_user.update_column :last_library_update, Time.now
    end

    if (current_user.last_recommendations_update.nil? or current_user.last_library_update > current_user.last_recommendations_update) and current_user.recommendations_up_to_date?
      current_user.update_column :recommendations_up_to_date, false
      RecommendingWorker.perform_async(current_user.id)
    end
  end
  
  def index
    @hide_cover_image = true
    
    update_recommendations_if_needed

    respond_to do |format|
      format.json { render :json => current_user.recommendations_up_to_date }
      format.html do
        # Uncomment for synchronous recommendations.
        # RecommendingWorker.new.perform(current_user.id)
        
        # Load recommended anime.
        r = current_user.recommendation
        @status_categories = ["currently_watching", "plan_to_watch", "completed"]
        @recommendations = {}
        @status_categories.each do |cat|
          @recommendations[cat] = JSON.parse(r.recommendations["by_status"])[cat].map {|x| Anime.find(x) } rescue []
        end

        @genre_recommendations = {}
        current_user.favorite_genres.each do |genre|
          @genre_recommendations[ genre.slug ] = JSON.parse(r.recommendations["by_genre"])[genre.slug].map {|x| Anime.find(x) } rescue []
        end

        @neon_alley = JSON.parse(r.recommendations["by_service"])["neon_alley"].map {|x| Anime.find(x) } rescue []
        
        # View convenience variables. Move to translations later.
        @word_before = {
          "currently_watching" => "you're",
          "plan_to_watch" => "you",
          "completed" => "you've"
        }
      end
    end
  end

  def not_interested
    anime = Anime.find params[:anime]
    unless current_user.not_interested_anime.include? anime
      current_user.not_interested_anime.push anime
      mixpanel.track "Recommendations: Not Interested", {email: current_user.email, anime: anime.slug} if Rails.env.production?
      current_user.update_column :last_library_update, Time.now
    end
    update_recommendations_if_needed
    render :json => true
  end

  def plan_to_watch
    anime = Anime.find params[:anime]
    watchlist = Watchlist.find_or_create_by_anime_id_and_user_id(anime.id, current_user.id)
    watchlist.status = "Plan to Watch"
    watchlist.save
    mixpanel.track "Recommendations: Plan to Watch", {email: current_user.email, anime: anime.slug} if Rails.env.production?
    update_recommendations_if_needed
    render :json => true
  end
end
