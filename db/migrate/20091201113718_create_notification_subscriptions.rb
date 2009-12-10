class CreateNotificationSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :notification_subscriptions do |t|
      t.text :event               # :after_create 
      t.text :source_type         # Instance
      t.text :source_filter       # { :entity_id => 1453 }
      t.text :destination_type    # :user
      t.text :destination         # 234
      t.text :protocol            # :smtp
    end
  end

  def self.down
    drop_table :notification_subscriptions
  end
end
