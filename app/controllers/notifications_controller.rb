class NotificationsController < ApplicationController
  before_filter :authenticate_user!

  def show
    hide_cover_image
    @notifications = Notification.where(user_id: current_user)
    @unseen_notification_count = @notifications.where(seen: false).count
    @notifications = @notifications.order("created_at DESC").limit(50)
    render :show
    @notifications.where(seen: false).each {|x| x.update_column :seen, true }
    if @notifications.count > 10
      Notification.where(user_id: current_user, seen: true).order("created_at").limit(@notifications.count - 10).each {|x| x.destroy }
    end
    Rails.cache.delete(:"#{current_user.id}_unseen_notifications")
  end
end
