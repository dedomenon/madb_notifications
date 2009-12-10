class MadbNotifications::NotificationSubscriptionsController < ApplicationController
  before_filter :login_required

  def toggle_creation_notification
    entity = Entity.find params[:id]
    subscribing = params[:value]=="true"
    if subscribing
      entity.subscribe_user_to_creation(current_user.id)
    else
      entity.unsubscribe_user_to_creation(current_user.id)
    end
    render :json => { :success => true, :data => { :subscribed => subscribing } }
  end

end
