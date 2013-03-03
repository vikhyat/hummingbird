class BetaInvite < ActiveRecord::Base
  attr_accessible :email, :invited, :token
  
  validates :email, uniqueness: true

  before_save do
    self.token ||= SecureRandom.hex
  end

  def self.valid_token?(token)
    beta_invite = BetaInvite.find_by_token(token)
    return false unless beta_invite
    beta_invite.valid_token?
  end
  
  def valid_token?
    # FIXME return false if the user has already signed up.
    true
  end
  
  def invite!
    self.invited = true
    self.save
    BetaMailer.delay.beta_invite(self)
  end
end
