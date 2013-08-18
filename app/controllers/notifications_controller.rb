class NotificationsController < ApplicationController
  before_filter :authenticate_user!

  def index
    hide_cover_image
    @notifications = Notification.where(user_id: current_user)
    @unseen_notification_count = @notifications.where(seen: false).count
    @notifications = @notifications.order("created_at DESC").limit(50)
    render :index
    @notifications.where(seen: false).each {|x| x.update_column :seen, true }
    if @notifications.count > 10
      Notification.where(user_id: current_user, seen: true).order("created_at").limit(@notifications.count - 10).each {|x| x.destroy }
    end
    Notification.uncache_notification_cache(current_user.id)
  end

  def show
    notification = Notification.find_by_id(params[:id])
    if notification.nil? or notification.user != current_user
      redirect_to :back
    else
      notification.update_attributes(seen: true)
      if notification.notification_type == "profile_comment"
        redirect_to user_path(current_user)
      end
    end
  end
end
