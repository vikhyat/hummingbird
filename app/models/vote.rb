# == Schema Information
#
# Table name: votes
#
#  id          :integer          not null, primary key
#  target_id   :integer          not null
#  target_type :string(255)      not null
#  user_id     :integer          not null
#  positive    :boolean          default(TRUE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Vote < ActiveRecord::Base
  belongs_to :target, polymorphic: true
  belongs_to :user
  attr_accessible :user, :target, :positive

  validate :check_target_accepts_negative
  def check_target_accepts_negative
    unless self.positive? or self.target.respond_to?(:total_votes)
      errors.add(:positive, "must be true")
    end
  end

  def self.for(user, target)
    Vote.where(user_id: user.id, target_id: target.id, target_type: target.class.name).first
  end

  after_create do
    if self.target.respond_to? :total_votes
      self.target_type.constantize.increment_counter 'total_votes', self.target_id
    end
    if self.positive?
      self.target_type.constantize.increment_counter 'positive_votes', self.target_id
    end
  end

  after_destroy do
    if self.target.respond_to? :total_votes
      self.target_type.constantize.decrement_counter 'total_votes', self.target_id
    end
    if self.positive?
      self.target_type.constantize.decrement_counter 'positive_votes', self.target_id
    end
  end

  before_save do
    if self.persisted? and self.positive_changed?
      if self.positive and !self.positive_was
        self.target_type.constantize.increment_counter 'positive_votes', self.target_id
      elsif !self.positive and self.positive_was
        self.target_type.constantize.decrement_counter 'positive_votes', self.target_id
      end
    end
  end
end
