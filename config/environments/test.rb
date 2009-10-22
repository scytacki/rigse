# Settings specified here will take precedence over those in config/environment.rb
puts "loading test environment"
# The test environment is used exclusively to run your application's
# test suite.  You never need to work with it otherwise.  Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs.  Don't rely on the data there!
config.cache_classes = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false

# Disable request forgery protection in test environment
config.action_controller.allow_forgery_protection    = false

# Tell Action Mailer not to deliver emails to the real world.
# The :test delivery method accumulates sent emails in the
# ActionMailer::Base.deliveries array.
config.action_mailer.delivery_method = :test

# current customizations below this line ...

# Install the gems required for development:
#
#   sudo env RAILS_ENV=test rake gems:install
#

# See: http://wiki.github.com/dchelimsky/rspec/configgem-for-rails
config.gem "rspec",        :lib => false,          :version => "= 1.2.9" 
config.gem "rspec-rails",  :lib => false,          :version => "= 1.2.9"
config.gem "webrat",       :lib => false,          :version => "= 0.4.4"
config.gem "cucumber",     :lib => false,          :version => "= 0.4.2"
config.gem "factory_girl", :lib => "factory_girl", :version => "= 1.2.3", :source => "http://gemcutter.org"

# See: http://remarkable.rubyforge.org/
# and: http://github.com/carlosbrando/remarkable/tree/master
# Adds new rspec matchers for models and controllers
# as well as better support for I18n, collections, creating custom matchers 
config.gem "remarkable_rails", :lib => false, :version => ">= 3.1.11"