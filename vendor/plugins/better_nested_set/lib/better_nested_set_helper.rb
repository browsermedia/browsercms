module SymetrieCom
  module Acts #:nodoc:
    
    # This module provides some helpers for the model classes using acts_as_nested_set.
    # It is included by default in all views. If you need to remove it, edit the last line
    # of init.rb.
    #
    module BetterNestedSetHelper
      
      # Prints a line of ancestors with links, on the form 
      #    root > parent > item
      #
      # == Usage
      # Default is to use links to {your_cotroller}/show with the first string column of your model.
      # You can tweak this by passing your parameters, or better, pass a block that will receive
      # an item from your nested set tree and a boolean flag (true for current item) and that 
      # should return the line with the link.
      #
      # == Examples
      # 
      #   nested_set_full_outline(category)
      #
      #   # non standard actions and separators
      #   nested_set_full_outline(category, :action => :search, :separator => ' | ')
      #
      #   # with a block that will return the link to the item
      #   # note that the current item will lead to another action
      #   nested_set_full_outline(category) { |item, current?| 
      #       if current?
      #         link_to "#{item.name} (#{item.})", product_url(:action => :show_category, :category => item.whole_url)
      #       else
      #         link_to "#{item.name} (#{item.})", category_url(:action => :browse, :criteria => item.whole_url)
      #       end
      #     }
      #
      # == Params are: 
      # +item+ - the object to display
      # +hash+ - containing :
      #  * +text_column+ - the title column, defaults to the first string column of the model
      #  * +:action+ - the action to be called (defaults to :show)
      #  * +:controller+ - the controller name (defaults to the model name)
      #  * +:separator+ - the separator (defaults to >)
      #  * +&block+ - a block { |item, current?| ... item.name }
      #
      def nested_set_full_outline(item, options={})
        return if item.nil?
        raise 'Not a nested set model !' unless item.respond_to?(:acts_as_nested_set_options)
        
        options = {
          :text_column => options[:text_column] || item.acts_as_nested_set_options[:text_column],
          :action => options[:action] || :show,
          :controller => options[:controller] || item.class.to_s.underscore,
          :separator => options[:separator] || ' &gt; ' }
        
        s = ''
        for it in item.ancestors
          if block_given?
            s += yield(it) + options[:separator]
          else
            s += link_to( it[options[:text_column]], { :controller => options[:controller], :action => options[:action], :id => it }) + options[:separator]
          end
        end
        if block_given?
          s + yield(item)
        else
          s + h(item[options[:text_column]])
        end
      end
  
      # Returns options for select.
      # You can exclude some items from the tree.
      # You can pass a block receiving an item and returning the string displayed in the select.
      #
      # == Usage
      # Default is to use the whole tree and to print the first string column of your model.
      # You can tweak this by passing your parameters, or better, pass a block that will receive
      # an item from your nested set tree and that should return the line with the link.
      #
      # == Examples
      #
      #   nested_set_options_for_select(Category)
      #
      #   # show only a part of the tree, and exclude a category and its subtree
      #   nested_set_options_for_select(selected_category, :exclude => category)
      #
      #   # add a custom string
      #   nested_set_options_for_select(Category, :exclude => category) { |item| "#{'&nbsp;' * item.level}#{item.name} (#{item.url})" }
      #
      # == Params
      #  * +class_or_item+ - Class name or item or array of items to start the display with
      #  * +text_column+ - the title column, defaults to the first string column of the model
      #  * +&block+ - a block { |item| ... item.name }
      #    If no block passed, uses {|item| "#{'··' * item.level}#{item[text_column]}"}
      def nested_set_options_for_select(class_or_item, options=nil)
        # find class
        if class_or_item.is_a? Class
          first_item = class_or_item.roots
        else
          first_item = class_or_item
        end       
        return [] if first_item.nil?
        raise 'Not a nested set model !' unless class_or_item.respond_to?(:acts_as_nested_set_options)
        
        # exclude some items and all their children
        if options.is_a? Hash
          text_column = options[:text_column]
          options.delete_if { |key, value| key != :exclude }
        else
          options = nil
        end
        text_column ||= class_or_item.acts_as_nested_set_options[:text_column]
        
        if first_item.is_a?(Array)
          tree = first_item.collect{|i| i.full_set(options)}.flatten
        else
          tree = first_item.full_set(options)
        end
        if block_given?
          tree.map{|item| [yield(item), item.id] }
        else  
          tree.map{|item| [ "#{'··' * item.level}#{item[text_column]}", item.id]}
        end
      end  
    end
  end  
end

