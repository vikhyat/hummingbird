class RecommendationsController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @hide_cover_image = true
    
    if current_user.last_library_update.nil?
      current_user.update_column :last_library_update, Time.now
    end

    if current_user.last_recommendations_update.nil? or current_user.last_library_update > current_user.last_recommendations_update
      current_user.update_column :recommendations_up_to_date, false
      RecommendingWorker.perform_async(current_user.id)
    end
    
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
      current_user.update_column :last_library_update, Time.now
    end
    render :json => true
  end
end
