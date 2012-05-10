module Cms
  module Behaviors
    module Searching
      def self.included(model_class)
        model_class.extend(MacroMethods)
      end
      module MacroMethods
        def searchable?
          !!@is_searchable
        end
        def is_searchable(options={})
          @is_searchable = true
          @searchable_columns = options[:searchable_columns] ? options[:searchable_columns].map(&:to_sym) : [:name]
          extend ClassMethods
        
          #This is in a method to allow classes to override it
          scope :search, lambda{|search_params|
            term = search_params.is_a?(Hash) ? search_params[:term] : search_params
            conditions = []
            unless term.blank?
              searchable_columns.each do |c|
                if conditions.empty?
                  conditions = ["#{table_name}.#{c} like ?"]
                else
                  conditions.first << "or #{table_name}.#{c} like ?"
                end
                conditions << "%#{term}%"
              end
              conditions[0] = "(#{conditions[0]})"
            end
            scope = {}
            scope[:conditions] = conditions if conditions
            scope
          }
        end
      end
      module ClassMethods
        def searchable_columns
          @searchable_columns
        end
      end
    end
  end
end
