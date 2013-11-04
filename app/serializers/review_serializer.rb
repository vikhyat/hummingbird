class ReviewSerializer < ActiveModel::Serializer
  embed :ids, include: true

  attributes :id, :summary, :rating
  has_one :user, embed_key: :name
  has_one :anime, embed_key: :slug

  def summary
    object.summary || HTML::FullSanitizer.new.sanitize(object.content).truncate(130, separator: ' ', omission: '...')
  end

  def rating
    object.rating / 2.0
  end

  def attributes
    hash = super
    hash["user_id"] = object.user.name
    hash
  end
end
