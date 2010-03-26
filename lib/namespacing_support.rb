# The goal here is to quietly make ActiveRecord namespace table names, so that
# Helpdesk::Ticket will just have 'helpdesk_tickets' as its tablename without
# any fuss, if you include NamespacingSupport::ActiveRecord::Base in that class
#
# This version does not allow you to include it 
#
# It also adds Module.namespaced? for your convenience
#
module NamespacingSupport
  module Module
    def namespaced?
      namespaces.any?
    end
    
    def namespaces
      self.to_s.split("::")[0...-1]
    end   
    
    def namespace
      namespaces * "::"
    end
    
  end
  
  # This is a rather tortuous way of allowing an ActiveRecord::Base subclass to
  # alias_method_chain the private method which most neatly allows us to force
  # namespaced table names.
  #
  # The indirect way we call is pure rather than idiomatic Ruby and avoids the
  # use of Object#send to evade method visibility restrictions
  #
  module ActiveRecord
    module Base
      def self.included(base)
        base.class_eval do           
          set_table_name "#{namespace.underscore!}_#{base_class.table_name}"
        end
      end
    end
  end
  
  module Inflector
    def namespaced_underscore(camel_cased_word)
      camel_cased_word.to_s.split("::").map(&:underscore).join("-")
    end
    
    def namespaced_constantize(underscored_string)
      underscored_string.split("-").map(&:camelize).join("::").constantize
    end
  end
  
  module Inflections
    def namespaced_underscore
      ActiveSupport::Inflector::Inflections.namespaced_underscore(self)
    end
    
    def namespaced_constantize
      ActiveSupport::Inflector::Inflections.namespaced_constantize(self)
    end
  end
    
end

class Module
  include NamespacingSupport::Module
end


