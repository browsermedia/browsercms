module Cms
  module Extensions
    module ActiveRecord

      module Base
        def updated_on_string(fmt="%b %e, %Y")
          if respond_to?(:updated_at) && updated_at
            updated_at.strftime(fmt).gsub(/\s{2,}/," ")
          else
            nil
          end
        end
      end

      module ClassMethods
        # Determines if the database for this Rails App exists yet. Useful for methods which might be called during
        # rake tasks or initialize where a database not yet being created is not fatal, but should be ignored.
        #
        # @return [Boolean] false if it does not exist.
        def database_exists?
          begin
            connection
            return true
          rescue StandardError # Hopefully this works with MySql, MySql2 and SQLite
            logger.warn "Attempted to establish a connection with the database, but could not do so."
            return false
          end

        end
      end
    end
  end
end
ActiveRecord::Base.send(:include, Cms::Extensions::ActiveRecord::Base)
ActiveRecord::Base.extend(Cms::Extensions::ActiveRecord::ClassMethods)


