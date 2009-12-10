#require 'test_helper'
require File.dirname(__FILE__)+'/../../../../test/test_helper.rb'

class MadbNotificationsTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "Class is available" do
    assert [], NotificationSubscription.find(:all)
    assert_kind_of NotificationSubscription, NotificationSubscription.new
  end
  test "Entity creation subscriptions" do
    assert_nil Entity.find(14).user_subscribed_to_creation?(1000001)
    Entity.find(14).subscribe_user_to_creation(1000001)
    n= Entity.find(14).user_subscribed_to_creation?(1000001)
    assert_not_nil n
    assert_equal "smtp", n.protocol
    assert_equal "after_create", n.event
    assert_equal "Instance", n.source_type
    assert_equal "user", n.destination_type
    assert_equal "1000001", n.destination

    Entity.find(14).subscribe_user_to_creation(1000001)
    Entity.find(14).subscribe_user_to_creation(1000002)
    Entity.find(15).subscribe_user_to_creation(1000003)

    assert_equal 2, Entity.find(14).subscriptions_to_creation.size
    assert_equal 1, Entity.find(15).subscriptions_to_creation.size

    # test toggling of subscription
    Entity.find(14).toggle_user_subscription_to_creation(1000001)
    assert_nil Entity.find(14).user_subscribed_to_creation?(1000001)
    Entity.find(14).toggle_user_subscription_to_creation(1000001)
    assert_not_nil Entity.find(14).user_subscribed_to_creation?(1000001)


  end
end
