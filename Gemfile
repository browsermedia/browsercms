#source 'http://rubygems.org'
source :gemcutter

gem "rails", "3.0.0"     # get 3.0.0.beta3
#gem "sqlite3-ruby", :require => "sqlite3"
gem "mysql"

# Gem Environments
group :test do
#  gem "redgreen"
#  gem 'factory_girl'
  gem 'factory_girl', :git => 'git://github.com/szimek/factory_girl.git', :branch => 'rails3'

  # :require=>false allows mocha to correctly modify the test:unit code to add mock() and stub()
  gem "mocha", '=0.9.8', :require=>false
end

