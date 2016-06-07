# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Protrack::Application.initialize!
APN::App::RAILS_ENV = "production"
#Rails.env
#"production"
