# IMPORTANT: This file is generated by cucumber-rails - edit at your own peril.
# It is recommended to regenerate this file in the future when you upgrade to a 
# newer version of cucumber-rails. Consider adding your own code to a new file 
# instead of editing this one. Cucumber will automatically load all features/**/*.rb
# files.

ENV["RAILS_ENV"] ||= "cucumber"
require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')

require 'cucumber/formatter/unicode' # Remove this line if you don't want Cucumber Unicode support
require 'cucumber/rails/rspec'
require 'cucumber/rails/world'
require 'cucumber/rails/active_record'
require 'cucumber/web/tableish'

require 'capybara/rails'
require 'capybara/cucumber'
require 'capybara/session'
require 'cucumber/rails/capybara_javascript_emulation' # Lets you click links with onclick javascript handlers without using @culerity or @javascript


require 'email_spec/cucumber'

# Capybara defaults to XPath selectors rather than Webrat's default of CSS3. In
# order to ease the transition to Capybara we set the default here. If you'd
# prefer to use XPath just remove this line and adjust any selectors in your
# steps to use the XPath syntax.
Capybara.default_selector = :css

# If you set this to false, any error raised from within your app will bubble 
# up to your step definition and out to cucumber unless you catch it somewhere
# on the way. You can make Rails rescue errors and render error pages on a
# per-scenario basis by tagging a scenario or feature with the @allow-rescue tag.
#
# If you set this to true, Rails will rescue all errors and render error
# pages, more or less in the same way your application would behave in the
# default production environment. It's not recommended to do this for all
# of your scenarios, as this makes it hard to discover errors in your application.
ActionController::Base.allow_rescue = false

# If you set this to true, each scenario will run in a database transaction.
# You can still turn off transactions on a per-scenario basis, simply tagging 
# a feature or scenario with the @no-txn tag. If you are using Capybara,
# tagging with @culerity or @javascript will also turn transactions off.
#
# If you set this to false, transactions will be off for all scenarios,
# regardless of whether you use @no-txn or not.
#
# Beware that turning transactions off will leave data in your database 
# after each scenario, which can lead to hard-to-debug failures in 
# subsequent scenarios. If you do this, we recommend you create a Before
# block that will explicitly put your database in a known state.
Cucumber::Rails::World.use_transactional_fixtures = true

# How to clean your database when transactions are turned off. See
# http://github.com/bmabey/database_cleaner for more info.
if defined?(ActiveRecord::Base)
  begin
    require 'database_cleaner'
    DatabaseCleaner.strategy = :truncation
  rescue LoadError => ignore_if_database_cleaner_not_present
  end
end

APP_CONFIG[:theme] = 'default' #lots of tests seem to be broken if we try to use another theme

# use factory girl:
require 'factory_girl'

Dir.glob(File.join(File.dirname(__FILE__), '../factories/*.rb')).each {|f| require f }

# This code used to live in factories/zz_default_data.rb.
# It boots the cucmber environement with a default project.
# required by application_controller.rb
puts "Loading default data set required for application_controller.rb to run ...."
anon =  Factory.next :anonymous_user
admin = Factory.next :admin_user 
device_config = Factory.create(:probe_device_config)
versioned_jnlp = Factory(:maven_jnlp_versioned_jnlp)
school = Factory(:portal_school)
domain = Factory(:rigse_domain)
grade = Factory(:portal_grade)
Admin::Project.create_or_update_default_project_from_settings_yml
puts "done."

# Make visible for testing
include AuthenticatedSystem
ApplicationController.send(:public, :logged_in?, :current_user, :authorized?)

# Cucumber Hooks: http://wiki.github.com/aslakhellesoy/cucumber/hooks
Before do
  # Could we get away with using mocks for projects and jnlps in capybara?
  # We shouldn't mock too many things in cucumber:
  # http://wiki.github.com/aslakhellesoy/cucumber/mocking-and-stubbing-with-cucumber
  puts "============================================"
  anon =  Factory.next :anonymous_user
  admin = Factory.next :admin_user 
  anon.skip_notifications = true
  admin.skip_notifications = true
  gse = Factory(:rigse_grade_span_expectation)
  device_config = Factory(:probe_device_config)
  versioned_jnlp = Factory(:maven_jnlp_versioned_jnlp)
  school = Factory(:portal_school)
  domain = Factory(:rigse_domain)
  grade = Factory(:portal_grade)
  Admin::Project.create_or_update_default_project_from_settings_yml
end

