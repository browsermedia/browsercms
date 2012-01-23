module Cms
  module ContentBlockHelper


    # Prints the <tr> for each block. Adds classes based on:
    # * Name/id of the block
    # * If a block is published/draft
    # * If the user can edit/publish it
    def block_row_tag(block)
      cname = class_name_for(block)
      can_modify = current_user.able_to_modify?(block)

      options = {
          :id => "#{cname}_#{block.id}",
          :class => cname
      }
      options[:class] += block.class.publishable? && !block.published? ? ' draft' : ' published'
      options[:class] += ' non-editable' unless can_modify && current_user.able_to?(:edit_content)
      options[:class] += ' non-publishable' unless can_modify && current_user.able_to?(:publish_content)
      tag "tr", options, true
    end

    def class_name_for(block)
      block.class.name.underscore
    end
  end
end