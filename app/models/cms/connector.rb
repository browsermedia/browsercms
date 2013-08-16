module Cms
  class Connector < ActiveRecord::Base

    belongs_to :page, :class_name => 'Cms::Page'
    belongs_to :connectable, :polymorphic => true

    extend DefaultAccessible
    #attr_accessible :connectable, :page_version, :connectable_version, :container # Need to be explicit due to seed data loading

    acts_as_list :scope => "#{Connector.table_name}.page_id = \#{page_id} and #{Cms::Connector.table_name}.page_version = \#{page_version} and #{Cms::Connector.table_name}.container = '\#{container}'"
    alias :move_up :move_higher
    alias :move_down :move_lower

    class << self
      def for_page_version(pv)
        where(:page_version => pv)
      end

      def for_connectable_version(cv)
        where(:connectable_version => cv)
      end

      def for_connectable(c)
        where(:connectable_id => c.id, :connectable_type => c.class.base_class.name)
      end

      def in_container(container)
        where(:container => container)
      end

      def at_position(position)
        where(:position => position)
      end

      def like(connector)
        where(:connectable_id => connector.connectable_id,
              :connectable_type => connector.connectable_type,
              :connectable_version => connector.connectable_version,
              :container => connector.container,
              :position => connector.position)
      end
    end

    validates_presence_of :page_id, :page_version, :connectable_id, :connectable_type, :container

    def current_connectable
      if versioned?
        connectable.as_of_version(connectable_version) if connectable
      else
        get_connectable
      end
    end

    def connectable_with_deleted
      c = if connectable_type.constantize.respond_to?(:find_with_deleted)
            connectable_type.constantize.find_with_deleted(id: connectable_id)
          else
            connectable_type.constantize.find(connectable_id)
          end
      (c && c.class.versioned?) ? c.as_of_version(connectable_version) : c
    end

    def status
      live? ? 'published' : 'draft'
    end

    def status_name
      status.to_s.titleize
    end

    def live?
      if publishable?
        connectable.live?
      else
        true
      end
    end

    def publishable?
      connectable_type.constantize.publishable?
    end

    def versioned?
      connectable_type.constantize.versioned?
    end

    # Determines if a connector should be copied when a page is updated/versioned, etc.
    #
    #
    def should_be_copied?
      if connectable && (!connectable.respond_to?(:draft) || !connectable.draft.deleted?)
        return true
      end


      false
    end
  end
end