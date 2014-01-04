class Vote < ActiveRecord::Base
  belongs_to :target, polymorphic: true
  belongs_to :user
  attr_accessible :user, :target, :positive

  after_create do
    self.target_type.constantize.increment_counter 'total_votes', self.target_id
    if self.positive?
      self.target_type.constantize.increment_counter 'positive_votes', self.target_id
    end
  end

  after_destroy do
    self.target_type.constantize.decrement_counter 'total_votes', self.target_id
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
