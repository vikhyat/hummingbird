class UserSyncWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find(user_id)
    open("http://forums.hummingbird.me/sync?secret=a2256cbca0c5ba922da96e394527a0a6959912d03152230&auth_token=#{user.authentication_token}").read
  end
end
