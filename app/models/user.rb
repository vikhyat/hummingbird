class User < ActiveRecord::Base
  # Friendly ID.
  def to_param
    name
  end

  def self.find(id)
    where('LOWER(name) = ?', id.to_s.downcase).first || super
  end

  # Following stuff.
  has_many :follower_relations, dependent: :destroy, foreign_key: :followed_id, class_name: 'Follow'
  has_many :followers, through: :follower_relations, source: :follower, class_name: 'User'

  has_many :following_relations, dependent: :destroy, foreign_key: :follower_id, class_name: 'Follow'
  has_many :following, through: :following_relations, source: :followed, class_name: 'User'

  has_many :stories
  has_many :substories
  has_many :notifications

  has_one :recommendation
  has_many :not_interested
  has_many :not_interested_anime, through: :not_interested, source: :media, source_type: "Anime"

  has_and_belongs_to_many :favorite_genres, class_name: "Genre", uniq: true, join_table: "favorite_genres_users"
  
  # Include devise modules. Others available are:
  # :lockable, :timeoutable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :trackable, :validatable, :omniauthable, :confirmable, :async,
         :token_authenticatable, allow_unconfirmed_access_for: 3.days

  # Remember users by default.
  def remember_me; true; end

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me,
    :watchlist_hash, :recommendations_up_to_date, :avatar, :facebook_id, :bio,
    :forem_admin, :about, :cover_image, :sfw_filter, :star_rating, :ninja_banned

  has_attached_file :avatar,
    styles: {
      thumb: '190x190#', 
      thumb_small: '50x50#'
    },
    convert_options: {thumb_small: '-unsharp 2x0.5+1+0'},
    default_url: "http://placekitten.com/g/190/190"
  
  has_attached_file :cover_image, 
    styles: {thumb: {geometry: "760x250#", animated: false}},
    default_url: "http://hummingbird.me/default_cover.png",
    storage: :s3

  process_in_background :avatar, processing_image_url: '/assets/processing-avatar.jpg'

  has_many :watchlists
  has_many :reviews
  has_many :quotes

  has_one :staged_import

  has_reputation :karma, :source => [
    {reputation: :review_votes},
    {reputation: :quote_votes}
  ]

  has_reputation :review_votes, source: {reputation: :votes, of: :reviews}
  has_reputation :quote_votes,  source: {reputation: :votes, of: :quotes}

  # Validations
  validates :name,
    :presence   => true,
    :uniqueness => {:case_sensitive => false},
    :length => {minimum: 3, maximum: 20},
    :format => {:with => /\A[-_A-Za-z0-9]+\z/, 
      :message => "can only contain alphabets, numbers, dashes and underscores."}
  
  validates :facebook_id, allow_blank: true, uniqueness: true

  validates :title_language_preference, inclusion: {in: %w[canonical english romanized]}

  def to_s
    name
  end

  # Avatar
  def avatar_url
    # Gravatar
    # gravatar_id = Digest::MD5.hexdigest(email.downcase)
    # "http://gravatar.com/avatar/#{gravatar_id}.png?s=100"
    avatar.url(:thumb)
  end

  # Public: Is this user an administrator?
  #
  # For now, this will just check email addresses. In production, this should
  # check the user's ID as well.
  def admin?
    ["c@vikhyat.net", # Vik
     "josh@hummingbird.ly", # Josh
     "harlequinmarie@gmail.com", # Ashley
     "ryatt.tesla@gmail.com", # Ryatt
     "dev.colinl@gmail.com", # Psy
     "lazypanda39@gmail.com", # Cai
     "windowjunk@yahoo.com" # Tav
    ].include? email
  end

  # Public: Find a user corresponding to a Facebook account.
  #
  # If there is an account associated with the Facebook ID, return it.
  #
  # If there is no such account but `signed_in_resource` is not nil (meaning that
  # there is a user signed in), connect the user's account to this Facebook
  # account.
  #
  # If there is no user logged in, check to see if there is a user with the same
  # email address. If there is, connect that account to Facebook and return it.
  #
  # Otherwise, just create a new user and connect it to this Facebook account.
  #
  # Returns a user account corresponding to the given auth parameters.
  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    # Try to find a user already associated with the Facebook ID.
    user = User.where(facebook_id: auth.uid).first
    return user if user
    
    # If the user is logged in, connect their account to Facebook.
    if not signed_in_resource.nil?
      signed_in_resource.connect_to_facebook(auth.uid)
      return signed_in_resource
    end
    
    # If there is a user with the same email, connect their account to this
    # Facebook account.
    user = User.find_by_email(auth.info.email)
    if user
      user.connect_to_facebook(auth.uid)
      return user
    end

    # Just create a new account. >_>
    name = auth.extra.raw_info.name.parameterize
    name = name.gsub(/[^-_A-Za-z0-9]/, '')
    if User.where("LOWER(name) = ?", name.downcase).count > 0
      if name.length > 20
        name = name[0...15]
      end
      name = name + rand(9999).to_s
    end
    name = name[0...20] if name.length > 20
    user = User.new(
      name: name,
      facebook_id: auth.uid,
      email: auth.info.email,
      avatar: URI.parse("http://graph.facebook.com/#{auth.uid}/picture?width=200&height=200"),
      password: Devise.friendly_token[0, 20]
    )
    user.save
    user.confirm!
    return user
  end
  
  # Set this user's facebook_id to the passed in `uid`.
  #
  # Returns nothing.
  def connect_to_facebook(uid)
    if not self.avatar.exists?
      self.avatar = URI.parse("http://graph.facebook.com/#{uid}/picture?width=200&height=200")
    end
    self.facebook_id = uid
    self.save
  end

  # Public: Return a hash table which returns false for all of the shows the user
  #         doesn't have on their watchlist, and the watchlist object for shows
  #         which they do have on.
  def watchlist_table
    watchlist = Hash.new(false)
    Watchlist.where(:user_id => id).each do |watch|
      watchlist[ watch.anime_id ] = watch
    end
    watchlist
  end

  # Return the top 3 genres the user has watched, along with a percentage of
  # anime watched that contain each of those genres.
  def top_genres
    genres        = Arel::Table.new(:genres)
    anime_genres  = Arel::Table.new(:anime_genres)
    watchlists_t  = Arel::Table.new(:watchlists)
    
    mywatchlists  = watchlists_t.where(watchlists_t[:user_id].eq(id))
    
    freqs = anime_genres.where(
              anime_genres[:anime_id].in( mywatchlists.project(:anime_id) )
            ).project(:genre_id, Arel.sql('COUNT(*) AS count'))
            .group(:genre_id).order('count DESC').take(3)
            
    result = {}
    
    connection.execute(freqs.to_sql).each do |h|
      result[ Genre.find(h["genre_id"]) ] = h["count"].to_f / watchlists.length
    end
    
    result
  end

  # How many minutes the user has spent watching anime.
  def recompute_life_spent_on_anime
    t = 0
    self.watchlists.each do |w|
      t += (w.anime.episode_length || 0) * (w.episodes_watched || 0)
      t += (w.anime.episode_count || 0) * (w.anime.episode_length || 0) * (w.rewatched_times || 0)
    end
    self.life_spent_on_anime = t
    self.save
  end
  
  def update_life_spent_on_anime(delta)
    if life_spent_on_anime.nil?
      self.recompute_life_spent_on_anime
    else
      self.life_spent_on_anime += delta
      self.save
    end
  end

  # Forem permissions
  def can_read_forem_category?(category); true;       end
  def can_read_forem_forums?;             true;       end
  def can_read_forem_forum?(forum);       true;       end
  def can_read_forem_topic?(topic);       true;       end
  def can_create_forem_topic?(topic);     persisted?; end
  def can_reply_to_forem_topic?(topic);   persisted?; end
  def can_edit_forem_posts?(forum);       true;       end

  searchable do
    text :name, as: :name_fuzzy
    text :email
  end

  def followers_count
    followers_count_hack
  end

  def last_seen
    reply = $redis.hget("user_last_seen", id.to_s)
    if reply
      Time.at reply.to_i
    else
      nil
    end
  end

  def compute_watchlist_hash
    watchlists = self.watchlists.order(:id).map {|x| [x.id, x.status, x.rating] }
    Digest::MD5.hexdigest( watchlists.inspect )
  end

  before_save do
    if self.facebook_id and self.facebook_id.strip == ""
      self.facebook_id = nil
    end
  end
end
