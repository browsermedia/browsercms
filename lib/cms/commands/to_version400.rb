module Cms
  module Commands
    module ToVersion400

      def generate_devise_configuration
        template 'devise.rb.erb', 'config/initializers/devise.rb'
      end
    end
  end
end
