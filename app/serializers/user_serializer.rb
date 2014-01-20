class UserSerializer < ActiveModel::Serializer
  attributes :id, :username, :cover_image_url, :avatar_template, :rating_type, :mini_bio, :is_followed, :title_language_preference

  def id
    object.name
  end

  def username
    object.name
  end

  def cover_image_url
    object.cover_image.url(:thumb)
  end

  def avatar_template
    object.avatar_template
  end

  def rating_type
    object.star_rating? ? "advanced" : "simple"
  end

  def mini_bio
    object.bio
  end

  def is_followed
    if scope
      object.follower_relations.where(follower_id: scope.id).length > 0
    else
      false
    end
  end

  def include_title_language_preference?
    scope == object
  end
end

