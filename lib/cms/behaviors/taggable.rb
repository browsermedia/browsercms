module Cms
  module Behaviors
    module Taggable
      def self.included(model_class)
        model_class.extend(MacroMethods)
      end

      module MacroMethods
        def taggable?
          !!@is_taggable
        end

        def is_taggable(options={})
          @is_taggable = true
          @tag_separator = options[:separator] || " "

          has_many :taggings, :as => :taggable, :class_name => 'Cms::Tagging'
          has_many :tags, -> { order("#{Cms::Tag.table_name}.name") }, :class_name => 'Cms::Tag', :through => :taggings


          after_save :save_tags

          extend ClassMethods
          include InstanceMethods

        end
      end
      module ClassMethods
        def tagged_with(t)
          where(["#{Cms::Tag.table_name}.name = ?", t]).includes(:taggings => :tag).references(:tags)
        end

        def tag_cloud
          Cms::Tagging.cloud(base_class.name)
        end

        def tag_separator
          @tag_separator
        end
      end
      module InstanceMethods
        def tag_list
          @tag_list ||= tags.reload.map(&:name).join(self.class.tag_separator)
        end

        def tag_list=(tag_names)
          changed_attributes["tag_list"] = tag_list unless @tag_list == tag_names
          @tag_list = tag_names
        end

        def save_tags
          tag_list_tags = tag_list.to_s.split(self.class.tag_separator).map { |t| Cms::Tag.find_or_create_by(name: t.strip) }
          taggings.each do |tg|
            if tag_list_tags.include?(tg.tag)
              tag_list_tags.delete(tg.tag)
            else
              tg.destroy
            end
          end
          tag_list_tags.each { |t| taggings.create(:tag => t, :taggable => self) }
          self.tag_list = nil
        end
      end
    end
  end
end
