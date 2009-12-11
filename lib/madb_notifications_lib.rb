if AppConfig.send_notifications==true
# check prerequisites
  raise "You need to add the app_host in your settings to use the notifications plugin" unless AppConfig.app_host
  raise "This plugin depends on DelayedJob, please install it" unless Delayed::Job


#augment Entity class to enable the subscription to event notifications
  Entity.class_eval do
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
    def subscriptions_to_creation
      NotificationSubscription.find(:all, :conditions => [ "source_filter = ? AND event = ? and source_type = ? and destination_type = ?",  {:entity_id => self.id}.to_yaml , "after_create", "Instance", "user"  ])
    end
  end


#add plugin to the AppConfig with its view hook.
  AppConfig.plugins.push( {:name => :madb_notifications, :entities_list_top_buttons => "madb_notifications/entities/list"  } )

#This is the Smtp notification. 
#LAter it might be wize to put it in another file or module.
  class MadbSmtpNotification < Struct.new(:id, :instance)
    def perform
      @subscription = NotificationSubscription.find(id)
      deliver_method_name = "deliver_"+@subscription.event+"_"+@subscription.source_type.downcase
      addresses.each do |address|
        MadbSmtpNotifier.send(deliver_method_name,address, @subscription, instance)
      end
    end
    def addresses
      case @subscription.destination_type
      when "user"
        u = User.find(@subscription.destination)
        return [ u.email ]
      end
    end
  end

#Add the ArEvents code to Instance
  Instance.extend ArEvents

#Crete the listener
  class InstanceCreationListener
    def self.trigger(event, i)
      puts "#{event} instance with id #{i.id}"
      i.entity.subscriptions_to_creation.each do |notification|
        case notification.protocol
        when "smtp"
          puts "enqueing norification #{notification.id} for instans #{i.id}"
          Delayed::Job.enqueue( MadbSmtpNotification.new(notification.id, i) )
        end
      end
    end
  end

#and add the listener to the :after_create Instance listeners
  Instance.add_ar_event_listener(:after_create, InstanceCreationListener)

end
