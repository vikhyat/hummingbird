require_relative 'entities.rb'

class API_v1 < Grape::API
  version 'v1', using: :path, format: :json, vendor: 'hummingbird'
  formatter :json, lambda {|object, env| MultiJson.dump(object) }

  helpers do
    def warden; env['warden']; end
    def current_user
      if params[:auth_token] or cookies[:auth_token]
        user = User.find_by_authentication_token(params[:auth_token] || cookies[:auth_token])
        if user.nil?
          error!("Invalid authentication token", 401)
        end
        user
      else
        nil
      end
    end
    def user_signed_in?
      not current_user.nil?
    end
    def authenticate_user!
      if user_signed_in?
        return true
      else
        error!("401 Unauthenticated", 401)
      end
    end
    def current_ability
      @current_ability ||= Ability.new(current_user)
    end
    def find_user(id)
      begin
        if id == "me" and user_signed_in?
          current_user
        else
          User.find(id)
        end
      rescue
        error!("404 Not Found", 404)
      end
    end

    def present_watchlist(w, rating_type, title_language_preference)
      {
        id: w.id,
        episodes_watched: w.episodes_watched,
        last_watched: w.last_watched || w.updated_at,
        rewatched_times: w.rewatched_times,
        notes: w.notes,
        notes_present: (w.notes and w.notes.strip.length > 0),
        status: w.status.downcase.gsub(' ', '-'),
        private: w.private,
        rewatching: w.rewatching,
        anime: {
          slug: w.anime.slug,
          status: w.anime.status,
          url: "http://hummingbird.me/anime/#{w.anime.slug}",
          title: w.anime.canonical_title(title_language_preference),
          alternate_title: w.anime.alternate_title(title_language_preference),
          episode_count: w.anime.episode_count,
          cover_image: w.anime.poster_image_thumb,
          synopsis: w.anime.synopsis,
          show_type: w.anime.show_type
        },
        rating: {
          type: rating_type,
          value: w.rating
        }
      }
    end
  end

  desc "Return the user's timeline"
  params do
    optional :page, type: Integer
  end
  get '/timeline' do
    if user_signed_in?
      Entities::Story.represent(NewsFeed.new(current_user).fetch(params[:page]), current_user: current_user, title_language_preference: current_user.title_language_preference)
    else
      []
    end
  end

  resource :users do
    desc "Return authentication code"
    params do
      optional :username, type: String
      optional :email, type: String
      requires :password, type: String
    end
    post '/authenticate' do
      user = nil
      if params[:username]
        user = User.where("LOWER(name) = ?", params[:username]).first
      elsif params[:email]
        user = User.where("LOWER(email) = ?", params[:email]).first
      end
      if user.nil? or (not user.valid_password? params[:password])
        error!("Invalid credentials", 401)
      end
      user.reset_authentication_token! if user.authentication_token.nil?
      return user.authentication_token
    end

    desc "Return the current user."
    params do
      requires :username, type: String
    end
    get ':username' do
      user = find_user(params[:username])
      json = {
        name: user.name,
        avatar: user.avatar.url(:thumb),
        cover_image: user.cover_image.url(:thumb),
        about: user.about,
        bio: user.bio,
        karma: user.reputation_for(:karma),
        life_spent_on_anime: user.life_spent_on_anime,
        show_adult_content: !user.sfw_filter?,
        title_language_preference: user.title_language_preference,
        last_library_update: user.last_library_update,
        online: user.online?,
        following: (user_signed_in? and user.followers.include?(current_user))
      }
      if user == current_user
        json["email"] = user.email
      end
      json
    end

    desc "Return the entries in a user's library under a specific status."
    params do
      requires :user_id, type: String
      optional :status, type: String
      optional :page, type: Integer
      optional :title_language_preference, type: String
      optional :include_mal_id, type: String
    end
    get ':user_id/library' do
      if params[:page] and params[:page] > 1
        return []
      end

      user = find_user(params[:user_id])
      status = Watchlist.status_parameter_to_status(params[:status])

      watchlists = user.watchlists.includes(:anime)
      watchlists = watchlists.where(status: status) if status
      watchlists = watchlists.where(private: false) if user != current_user

      title_language_preference = params[:title_language_preference]
      if title_language_preference.nil? and current_user
        title_language_preference = current_user.title_language_preference
      end
      title_language_preference ||= "canonical"

      rating_type = user.star_rating? ? "advanced" : "simple"

      watchlists.map {|w| present_watchlist(w, rating_type, title_language_preference) }
    end

    desc "Returns the user's feed."
    params do
      requires :user_id, type: String
      optional :page, type: Integer
    end
    get ":user_id/feed" do
      user = find_user(params[:user_id])

      # Find stories to display.
      stories = user.stories.for_user(current_user).order('updated_at DESC').includes(:substories, :user, :target).page(params[:page]).per(20)

      present stories, with: Entities::Story, current_user: current_user, title_language_preference: (user_signed_in? ? current_user.title_language_preference : "canonical")
    end

    desc "Delete a substory from the user's feed."
    params do
      requires :user_id, type: String
      requires :substory_id, type: Integer
    end
    post ":user_id/feed/remove" do
      begin
        substory = Substory.find params[:substory_id]
      rescue
        return true
      end
      if current_user and (current_user.admin? or (current_user.id == substory.user_id) or (current_user.id == substory.story.user_id))
        substory.destroy
        return true
      else
        return false
      end
    end
  end

  resource :libraries do
    desc "Remove an entry"
    params do
      requires :anime_slug, type: String
    end
    post ':anime_slug/remove' do
      authenticate_user!

      anime = Anime.find(params["anime_slug"])
      watchlist = Watchlist.find_or_create_by_anime_id_and_user_id(anime.id, current_user.id)
      watchlist.destroy
      true
    end

    desc "Update a specific anime's details in a user's library."
    params do
      requires :anime_slug, type: String
      optional :increment_episodes, type: String
      optional :rewatching, type: String
    end
    post ':anime_slug' do
      authenticate_user!

      anime = Anime.find(params["anime_slug"])
      watchlist = Watchlist.find_or_create_by_anime_id_and_user_id(anime.id, current_user.id)

      # Update status.
      if params[:status]
        status = Watchlist.status_parameter_to_status(params[:status])
        if watchlist.status != status
          # Create an action if the status was changed.
          Substory.from_action({
            user_id: current_user.id,
            action_type: "watchlist_status_update",
            anime_id: anime.slug,
            old_status: watchlist.status,
            new_status: status,
            time: Time.now
          })
        end
        watchlist.status = status if Watchlist.valid_statuses.include? status
        if status == "Completed"
          # Mark all episodes as viewed when the show is "Completed".
          watchlist.update_episode_count (watchlist.anime.episode_count || 0)
        end
      end

      # Update privacy.
      if params[:privacy]
        if params[:privacy] == "private"
          watchlist.private = true
        elsif params[:privacy] == "public"
          watchlist.private = false
        end
      end

      # Update rating.
      if params[:rating]
        if watchlist.rating == params[:rating].to_i
          watchlist.rating = nil
        else
          watchlist.rating = [ [0, params[:rating].to_f].max, 5 ].min
        end
      end

      # Update rewatched_times.
      if params[:rewatched_times]
        watchlist.update_rewatched_times params[:rewatched_times]
      end

      # Update notes.
      if params[:notes]
        watchlist.notes = params[:notes]
      end

      # Update episode count.
      if params[:episodes_watched]
        watchlist.update_episode_count params[:episodes_watched]
      end

      # Update "rewatching" status.
      if params[:rewatching]
        watchlist.rewatching = (params[:rewatching] == "true")
      end

      if params[:increment_episodes] and params[:increment_episodes] == "true"
        watchlist.status = "Currently Watching"
        watchlist.update_episode_count((watchlist.episodes_watched||0)+1)
        if current_user.neon_alley_integration? and Anime.neon_alley_ids.include? anime.id
          service = "neon_alley"
        else
          service = nil
        end
        Substory.from_action({
          user_id: current_user.id,
          action_type: "watched_episode",
          anime_id: anime.slug,
          episode_number: watchlist.episodes_watched,
          service: service
        })
        if watchlist.status == "Completed"
          Substory.from_action({
            user_id: current_user.id,
            action_type: "watchlist_status_update",
            anime_id: anime.slug,
            old_status: "Currently Watching",
            new_status: "Completed",
            time: Time.now + 5.seconds
          })
        end
      end

      title_language_preference = params[:title_language_preference]
      if title_language_preference.nil? and current_user
        title_language_preference = current_user.title_language_preference
      end
      title_language_preference ||= "canonical"
      rating_type = current_user.star_rating? ? "advanced" : "simple"

      if watchlist.save
        present_watchlist(watchlist, rating_type, title_language_preference)
      else
        return false
      end
    end
  end

  resource :anime do
    desc "Return an anime"
    params do
      requires :id, type: String, desc: "anime ID"
      optional :title_language_preference, type: String
    end
    get ':id' do
      anime = Anime.find(params[:id])
      
      title_language_preference = params[:title_language_preference]
      if title_language_preference.nil? and current_user
        title_language_preference = current_user.title_language_preference
      end
      title_language_preference ||= "canonical"

      present anime, with: Entities::Anime, title_language_preference: title_language_preference
    end
    
    desc "Returns similar anime."
    params do
      requires :id, type: String, desc: "anime ID"
      optional :limit, type: Integer, desc: "number of results (max/default 20)"
    end
    get ':id/similar' do
      anime = Anime.find(params[:id])
      similar_anime = []
      similar_json = JSON.load(open("http://app.vikhyat.net/anime_safari/related/#{anime.id}")).sort_by {|x| -x["sim"] }
      similar_json.each do |similar|
        sim = Anime.find_by_id(similar["id"])
        similar_anime.push(sim) if sim and similar_anime.length < (params[:limit] || 20)
      end
      similar_anime.map {|x| {id: x.slug, title: x.canonical_title, alternate_title: x.alternate_title, genres: x.genres.map {|x| {name: x.name} }, cover_image: x.poster_image.url(:large), url: anime_url(x)} }
    end
  end

  desc "Anime search API endpoint"
  params do
    requires :query, type: String, desc: "query string"
  end
  get '/search/anime' do
    anime = Anime.accessible_by(current_ability).includes(:genres)
    results = anime.simple_search_by_title(params[:query]).limit(5)
    if results.length == 0
      results = anime.fuzzy_search_by_title(params[:query]).limit(5)
    end

    present results, with: Entities::Anime, title_language_preference: (current_user.try(:title_language_preference) || "canonical")
  end
end
