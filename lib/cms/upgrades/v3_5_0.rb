module Cms
  module Upgrades

    module V3_5_0
      def upgrade_to_3_5_0
        gsub_file "config/environments/production.rb", /config.action_controller.page_cache_directory.+$/, ""
      end
    end
  end
end