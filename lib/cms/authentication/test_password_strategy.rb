module Cms
  module Authentication
    # For testing external authentication.
    class TestPasswordStrategy < Devise::Strategies::Authenticatable
      EXPECTED_LOGIN = EXPECTED_PASSWORD = 'test'
      def authenticate!
        if(authentication_hash[:login] == password && password == EXPECTED_PASSWORD)
          user = Cms::ExternalUser.authenticate(authentication_hash[:login], 'Test Password', {first_name: "Test", last_name: "User"})
          user.authorize('cms-admin', 'content-editor')
          success!(user)
        else
          pass
        end
      end
    end
  end
end

Warden::Strategies.add(:test_password, Cms::Authentication::TestPasswordStrategy)

# NOTE:  To enable a custom password strategy for BrowserCMS you must also add it to to the devise configuration.
# 
# For example enable the test_password strategy above by adding the following to config/initializers/devise.rb

# # Add test_password strategy BEFORE other CMS authentication strategies
# config.warden do |manager|
#   manager.default_strategies(:scope => :cms_user).unshift :test_password
# end
