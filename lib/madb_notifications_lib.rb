# MadbNotifications
# notes: wanted to put the observer in a submodule, but caused troubles adding the observer
# Passing MadbInstanceObserver.instance didnt work
#    if ActiveRecord::Base.observers
#      ActiveRecord::Base.observers += [ :madb_instance_observer ] 
#    else
#      ActiveRecord::Base.observers = [ :madb_instance_observer ] 
#    end

class Entity < ActiveRecord::Base
  def user_subscribed_to_creation?(user_id)
    NotificationSubscription.find(:first, :conditions => [ "source_filter = ? AND event = ? and source_type = ? and destination_type = ? and destination = ?",  {:entity_id => self.id}.to_yaml , "after_create", "Instance", "user", user_id.to_s  ])
  end
  def toggle_user_subscription_to_creation(user_id)
    if user_subscribed_to_creation?(user_id)
      unsubscribe_user_to_creation(user_id)
    else
      subscribe_user_to_creation(user_id)
    end
  end
  def subscribe_user_to_creation(user_id)
    unless self.user_subscribed_to_creation?(user_id)
      n = NotificationSubscription.new(  :protocol => "smtp" ,  :event => "after_create", :source_type => "Instance", :destination_type => "user", :destination => user_id.to_s ) 
      n.source_filter = {:entity_id => self.id}.to_yaml 
      n.save
    end
  end
  def unsubscribe_user_to_creation(user_id)
    if  n = self.user_subscribed_to_creation?(user_id)
      n.destroy
    end
  end
end


AppConfig.plugins.push( {:name => :madb_notifications, :entities_list_top_buttons => "madb_notifications/entities/list"  } )


Instance.extend ArEvents
class InstanceListener
  def self.trigger(event, i)
    puts "#{event} instance with id #{i.id}"
  end
end
Instance.add_ar_event_listener(:after_create, InstanceListener)
#Instance.add_ar_event_listener(:after_destroy, InstanceListener)

#FileAttachment.send(:include, ArEvents)
#class FileAttachmentListener
#  def self.trigger(event, i)
#    puts "#{event} detail_value with id #{i.id}"
#  end
#end
#
#FileAttachment.add_ar_event_listener(:after_save, FileAttachmentListener)
#FileAttachment.add_ar_event_listener(:after_destroy, FileAttachmentListener)
#FileAttachment.add_ar_event_listener(:after_create, FileAttachmentListener)
