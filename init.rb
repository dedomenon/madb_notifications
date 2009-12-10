# Include hook code here

exit unless AppConfig.send_notifications
raise "You need to add the app_host in your settings to use the notifications plugin" unless AppConfig.app_host
raise "This plugin depends on DelayedJob, please install it" unless Delayed::Job

require  File.dirname(__FILE__)+'/lib/madb_notifications_lib.rb'

