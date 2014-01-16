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