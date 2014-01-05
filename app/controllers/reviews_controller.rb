class ReviewsController < ApplicationController
  def index
    respond_to do |format|
      format.html do
        @anime = Anime.find(params[:anime_id])
        preload! @anime
        render "anime/show", layout: "redesign"
      end
      format.json do
        if params[:anime_id]
          anime = Anime.find params[:anime_id]
          reviews = anime.reviews.order('wilson_score DESC').page(params[:page]).per(20)
        elsif params[:user_id]
          user = User.find params[:user_id]
          reviews = user.reviews.order('wilson_score DESC').page(params[:page]).per(20)
        end
        render json: reviews, meta: {page: (params[:page] || 1), total: reviews.total_pages}
      end
    end
  end

  def show
    @review = Review.find(params[:id])
    @anime = @review.anime
    @recent_reviews = Review.order('created_at DESC').limit(10).select {|x| x.anime.sfw? }
    if user_signed_in?
      @evaluation = Vote.for(current_user, @review)
    end
  end

  def vote
    authenticate_user!
    @review = Review.find(params[:id])
    vote = Vote.for(current_user, @review) || Vote.new(user: current_user, target: @review)
    vote.positive = params[:type] == "up"
    vote.save
    @review.reload.update_wilson_score!
    redirect_to :back
  end

  def new
    authenticate_user!
    @anime = Anime.find(params[:anime_id])
    if Review.exists?(user_id: current_user, anime_id: @anime)
      @review = Review.find_by_user_id_and_anime_id(current_user.id, @anime.id)
      redirect_to edit_anime_review_path(@anime, @review)
    else
      @review = Review.new(user: current_user)
    end
  end

  def create
    authenticate_user!

    @anime = Anime.find(params[:anime_id])
    @review = Review.find_by_user_id_and_anime_id(current_user.id, @anime.id)
    if @review.nil?
      @review = Review.new(user: current_user, anime: @anime)
    end

    @review.content = params["review"]["content"]
    @review.summary = params["review"]["summary"]
    @review.summary = nil if @review.summary.strip.length == 0
    @review.source  = "hummingbird"

    @review.rating = [[1, params["review"]["rating"].to_i].max, 10].min rescue nil
    @review.rating_story      = [[1, params["review"]["rating_story"].to_i].max, 10].min rescue nil
    @review.rating_animation  = [[1, params["review"]["rating_animation"].to_i].max, 10].min rescue nil
    @review.rating_sound      = [[1, params["review"]["rating_sound"].to_i].max, 10].min rescue nil
    @review.rating_character  = [[1, params["review"]["rating_character"].to_i].max, 10].min rescue nil
    @review.rating_enjoyment  = [[1, params["review"]["rating_enjoyment"].to_i].max, 10].min rescue nil

    if @review.save
      redirect_to anime_review_path(@anime, @review)
    else
      flash[:error] = "Couldn't save your review, something went wrong."
      redirect_to :back
    end
  end

  def edit
    authenticate_user!
    @anime  = Anime.find(params[:anime_id])
    @review = Review.find(params[:id])
    if @review.user != current_user
      flash[:error] = "You are not authorized to edit this review."
      redirect_to :back
    else
      # Logic
    end
  end

  def update
    create
  end
end
