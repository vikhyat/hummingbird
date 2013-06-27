class RecommendationsController < ApplicationController
  def index
    authenticate_user!
    @hide_cover_image = true
    
    new_watchlist_hash = current_user.compute_watchlist_hash + "b"
    if current_user.watchlist_hash != new_watchlist_hash
      current_user.update_attributes(
        watchlist_hash: new_watchlist_hash + "a",
        recommendations_up_to_date: false
      )
      RecommendingWorker.perform_async(current_user.id)
    end
    
    # FIXME This is temporary!
    # RecommendingWorker.new.perform(current_user.id)
    
    # Load recommended anime.
    r = current_user.recommendation
    @status_categories = ["currently_watching", "plan_to_watch", "completed"]
    @recommendations = {}
    @status_categories.each do |cat|
      @recommendations[cat] = r ? JSON.parse(r.recommendations["by_status"])[cat].map {|x| Anime.find(x) } : []
    end
    
    # View convenience variables. Move to translations later.
    @word_before = {
      "currently_watching" => "you're",
      "plan_to_watch" => "you",
      "completed" => "you've"
    }
  end
end
