class HomeController < ApplicationController
  def index
    @hide_cover_image = true
    @latest_reviews = Review.order('created_at DESC').limit(2)
    # @recent_anime = Watchlist.joins(:anime).where("(watchlists.status = 'Currently Watching' OR watchlists.status = 'Completed') AND anime.age_rating <> 'Rx'").order('watchlists.last_watched DESC').limit(8)
    @recent_anime = Watchlist.select("DISTINCT ON (user_id) *").where("(status = 'Currently Watching' OR status = 'Completed') AND EXISTS (SELECT 1 FROM users WHERE users.id = user_id) AND EXISTS (SELECT 1 FROM anime WHERE anime.id = anime_id AND anime.age_rating <> 'Rx')").limit(8)
    @featured_anime = Anime.where('slug IN (?)', %w[
      sword-art-online
      cuticle-detective-inaba
      blue-exorcist
      the-girl-who-leapt-through-time
    ])
    # Select one of these 9 background images.
    @background_image = %w[
      http://hakanai.vikhyat.net/system/gallery_images/images/000/000/076/original/blood.jpg?1361895445
      http://hakanai.vikhyat.net/system/gallery_images/images/000/000/074/original/another3.jpg?1361895288
      http://hakanai.vikhyat.net/system/gallery_images/images/000/000/072/original/another.jpg?1361895189
      http://hakanai.vikhyat.net/system/gallery_images/images/000/000/059/original/darker4.jpg?1361823103
      http://hakanai.vikhyat.net/system/gallery_images/images/000/000/058/original/darker3.jpg?1361823078
      http://hakanai.vikhyat.net/system/gallery_images/images/000/000/057/original/darker2.jpg?1361823056
      http://hakanai.vikhyat.net/system/gallery_images/images/000/000/056/original/darker.jpg?1361823028
      http://hakanai.vikhyat.net/system/gallery_images/images/000/000/136/original/melancholy.jpg?1362175820
      http://hakanai.vikhyat.net/system/gallery_images/images/000/000/137/original/melancholy3.jpg?1362175882
    ].sample
  end
  
  def dashboard
    authenticate_user!
    redirect_to user_path(current_user)
  end
end
