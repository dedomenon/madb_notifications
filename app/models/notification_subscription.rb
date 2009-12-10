class NotificationSubscription < ActiveRecord::Base
#the value in source_filter is actually yaml, but serialisation is not used as
#it didn't work correctly when searching for it afterwards
end
