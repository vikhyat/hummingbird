class Substory < ActiveRecord::Base
  belongs_to :user
  belongs_to :target, polymorphic: true
  belongs_to :story
  attr_accessible :user, :target, :story, :substory_type, :data
  serialize :data, ActiveRecord::Coders::Hstore
  validates :user, :substory_type, presence: true
  
  after_create do
    self.story.updated_at = self.created_at
    self.story.save
  end
  
  after_destroy do
    if self.story.reload.substories.length == 0
      self.story.destroy
    end
  end

  def self.from_action(data)
    user = User.find data[:user_id]

    if data[:action_type] == "followed"
      
      followed_user = User.find data[:followed_id]

      # Find or create a user story for this follow action.
      # If there already is a followed story for this user that was created less
      # than 6 hours ago, use that one. Otherwise create a new one.
      story = user.stories.where(story_type: 'followed').order("created_at DESC").limit(1)
      if story.length == 1 and story[0].created_at >= 6.hours.ago
        story = story[0]
      else
        story = Story.create user: user, story_type: "followed"
      end
      
      substory = Substory.create({
        user: user, 
        substory_type: "followed", 
        target: followed_user, 
        story: story
      })

    elsif data[:action_type] == "unfollowed"

      followed_user = User.find data[:followed_id]
      
      Substory.where(user_id: user.id, substory_type: "followed", target_id: followed_user.id, target_type: "User").each {|x| x.destroy }

    elsif data[:action_type] == "liked_quote"
      
      quote = Quote.find(data[:quote_id])
      
      # First, check to see if a substory for this quote already exists for this 
      # user. If so, don't do anything.
      if user.substories.where(substory_type: "liked_quote", target_id: quote, target_type: "Quote").length > 0
        return
      end
      
      # Otherwise, find the relevant story and add a substory to it.
      story = Story.for_user_and_anime(user, quote.anime, "media_story")

      substory = Substory.create({
        user: user, 
        substory_type: "liked_quote", 
        target: quote, 
        story: story
      })
      
    elsif data[:action_type] == "unliked_quote"

      quote = Quote.find(data[:quote_id])
      Substory.where(user_id: user.id, substory_type: "liked_quote", target_id: quote.id, target_type: "Quote").each {|x| x.destroy }

    elsif data[:action_type] == "submitted_quote"

      quote = Quote.find(data[:quote_id])

      story = Story.for_user_and_anime(user, quote.anime, "media_story")

      substory = Substory.create({
        user: user, 
        substory_type: "submitted_quote", 
        target: quote, 
        story: story
      })

    elsif data[:action_type] == "watchlist_status_update"

      anime = Anime.find data[:anime_id]
      story = Story.for_user_and_anime(user, anime)

      Substory.create({
        user: user,
        substory_type: "watchlist_status_update",
        story: story,
        data: {
          old_status: data[:old_status],
          new_status: data[:new_status]
        }
      })

    elsif data[:action_type] == "watched_episode"

      anime = Anime.find data[:anime_id]
      story = Story.for_user_and_anime(user, anime)

      Substory.create({
        user: user,
        substory_type: "watched_episode",
        story: story,
        data: {
          episode_number: data[:episode_number]
        }
      })
    end
  end
end
