class UserSerializer < ActiveModel::Serializer
  attributes :id, :username, :cover_image_url, :avatar_template, :about

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
end

