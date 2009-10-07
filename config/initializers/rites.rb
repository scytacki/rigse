# Don't create initial settings if we are building the app for the first time because the
# tables haven't been created yet. 
#
# This is one way to test to see if we got here running rake db:migrate:
#
#   unless ( File.basename($0) == "rake" && ARGV.include?("db:migrate") ) 
# 
# but it won't help when running a task like this the first time:
#
#   rake rigse:setup:new_rites_app
#
# So I'm using this method to find out if the standard "ActiveRecord::Base" 
# connection in the connection_pool is working:
#
#   ActiveRecord::Base.connection_handler.connection_pools["ActiveRecord::Base"].connection
#
# and counting on generating an error if the database has not yet been created
#
# This is only tested right now with mysql through both MRI and JRuby using jdbc and mysql.
#
# JRuby throws a RuntimeError
# 
#   RuntimeError: The driver encountered an error: com.mysql.jdbc.exceptions.MySQLSyntaxErrorException: 
#   Unknown database 'rites_development'
# 
# MRI throws a Mysql::Error. Unfortunately Mysql::Error isn't defined as a constant until 
# after the ActiveRecord statement that causes the error is called for the first time, but 
# Mysql::Error inherits from StandardError so that will do.
# 
#   Mysql::Error.ancestors
#   => [Mysql::Error, StandardError, ...
#
begin
  ActiveRecord::Base.connection_handler.connection_pools["ActiveRecord::Base"].connection
  puts "running Admin::Project.create_or_update__default_project_from_settings_yml"
  Admin::Project.create_or_update__default_project_from_settings_yml
rescue RuntimeError, StandardError
  puts "database doesn't exist ... run migrations or load a database schema"
  puts "not running Admin::Project.create_or_update__default_project_from_settings_yml"
end
