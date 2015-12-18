module Cms
  module ContentBlockHelper

    # From 3.3.x (Performance)
    # Delete once we confirm that content_block_tr_tag below works.

    # Prints the <tr> for each block. Adds classes based on:
    # * Name/id of the block
    # * If a block is published/draft
    # * If the user can edit/publish it
    def block_row_tag(block)
      cname = class_name_for(block)
      can_modify = current_cms_user.able_to_modify?(block)

      options = {
          :id => "#{cname}_#{block.id}",
          :class => cname
      }
      options[:class] += block.class.publishable? && !block.published? ? ' draft' : ' published'
      options[:class] += ' non-editable' unless can_modify && current_cms_user.able_to?(:edit_content)
      options[:class] += ' non-publishable' unless can_modify && current_cms_user.able_to?(:publish_content)
      tag "tr", options, true
    end

    # From 3.4.x (Namespaced and using Data elements to clean up JS in pages)
    
    # For each row in content block table, we need to output all the paths for the actions in a way that JS can read them.
    # We use 'data-' elements here to avoid duplication of path calculations.
    def content_block_tr_tag(block)
      cname = class_name_for(block)
      can_modify = current_cms_user.able_to_modify?(block)

      options = {}
      data = options[:data] = {}
      data[:status] = block.class.publishable? && !block.published? ? 'draft' : 'published'

      options[:id] = "#{cname}_#{block.id}"
      options[:class] = [cname]
      options[:class] << 'non-editable' unless can_modify && current_cms_user.able_to?(:edit_content)
      options[:class] << 'non-publishable' unless can_modify && current_cms_user.able_to?(:publish_content)
      options['data-new_path'] = url_for(new_engine_aware_path(block))
      options['data-view_path'] = url_for(engine_aware_path(block, nil))
      options['data-edit_path'] = url_for(edit_engine_aware_path(block))
      options['data-preview_path'] = block.path if block.class.addressable?
      options['data-versions_path'] = engine(block).polymorphic_path(block, action: :versions) if block.class.versioned?
      options['data-delete_path'] = url_for(engine_aware_path(block))
      options['data-publish_path'] = engine(block).polymorphic_path([:publish, block]) if block.class.publishable?
      tag "tr", options, true
    end

    def class_name_for(block)
      block.class.name.underscore
    end
  end
end