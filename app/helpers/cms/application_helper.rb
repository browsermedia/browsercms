# Methods added to this helper will be available to all templates in the cms.
module Cms
  module ApplicationHelper

    # Help with deprecations messages
    # @deprecated
    def cms_handler_path(*args)
      raise "The #cms_handler_path helper method has been removed from BrowserCMS. Use '#handler_path instead'."
    end

    def searchable_sections(selected = nil)
      root = Section.root.first
      options = [['All sections', 'all'], [root.name, root.id]]
      root.master_section_list.each { |s| options << [s.full_path, s.id] }
      options_for_select(options, selected.to_i)
    end

    def select_per_page
      options = [10, 20, 50, 100].collect { |c| ["#{c} per page", c] }
      select_tag("per_page", options_for_select(options, params[:per_page].to_i))
    end

    def page_versions(page)
      text = select_tag(:version,
                        options_for_select(page.versions.all(:order => "version desc").map { |r|
                          ["v#{r.version}: #{r.version_comment} by #{r.updated_by.login} at #{time_on_date(r.updated_at)}", r.version]
                        }, page.version),
                        :onchange => 'this.form.submit(); return false')
      text << javascript_tag("$('version').selectedIndex = 0") if page.live?
      text
    end

    def action_icon_src(name)
      "cms/icons/actions/#{name}.png"
    end

    def action_icon(name, options={})
      image_tag action_icon_src(name), {:alt => name.to_s.titleize}.merge(options)
    end

    def status_icon(status, options={})
      image_tag "cms/icons/status/#{status.to_s.underscore}.gif", {:alt => status.to_s.titleize}.merge(options)
    end

    def time_on_date(time)
      time && "#{time.strftime("%l:%M %p")} on #{time.strftime("%b %e, %Y")}"
    end

    def format_date(time)
      time && "#{time.strftime("%b %e, %Y")}"
    end

    # Renders two links that will check/uncheck a set of checkboxes.
    #
    # @param [String] selector The CSS selector for the checkboxes that should be mass checked/unchecked.
    def check_uncheck_tag(selector)
      check_id = to_id(selector, "check")
      uncheck_id = to_id(selector, "uncheck")
      content_for :html_head do
        html = <<HTML
jQuery(function($) {
  $('a##{check_id}').click(function() {
    $('#{selector}').attr('checked', true);
  });

  $('a##{uncheck_id}').click(function() {
    $('#{selector}').attr('checked', false);
  });
})
HTML
        javascript_tag html
      end

      "#{link_to "Check All", '#', :id => check_id}, #{link_to "Uncheck All", '#', :id => uncheck_id}".html_safe
    end

    # @deprecated Use check_uncheck_tag instead. Retained for backwards compatibility w/ CMS implementations.
    def link_to_check_all(selector, name="Check All")
      id = to_id(selector, "check")
      content_for :html_head do
        html = <<HTML
jQuery(function($) {
  $('a##{id}').click(function() {
    $('#{selector}').attr('checked', true);
  });
})
HTML
        javascript_tag html
      end
      link_to name, '#', :id => id
    end

    # @deprecated Use check_uncheck_tag instead. Retained for backwards compatibility w/ CMS implementations.
    def link_to_uncheck_all(selector, name="Uncheck All")
      id = to_id(selector, "uncheck")
      content_for :html_head do
        html = <<HTML
jQuery(function($) {
  $('a##{id}').click(function() {
    $('#{selector}').attr('checked', false);
  });
})
HTML
        javascript_tag html
      end
      link_to name, '#', :id => id
    end

    def span_tag(content)
      content_tag :span, content
    end



    def dk_button_wrapper(content)
      (content).gsub("lt_button_", "dk_button_")
    end

    def group_ids
      (params[:group_ids] || @user.group_ids).collect { |g| g.to_i }
    end

    def group_filter
      select_tag("group_id", options_from_collection_for_select(Group.all.insert(0, Group.new(:id => nil, :name => "Show All Groups")), "id", "name", params[:group_id].to_i))
    end

    # Fetches a list of categories for a cms_drop_down. Will prompt users to create Categories/Categories types if the proper ones don't exist.
    def categories_for(category_type_name, order="name")
      cat_type = CategoryType.named(category_type_name).first
      categories = cat_type ? cat_type.category_list(order) : [Category.new(:name => "-- You must first create a 'Category Type' named '#{category_type_name}'")]
      categories.empty? ? [Category.new(:name => "-- You must first create a Category with a Category Type of '#{category_type_name}'.")] : categories
    end

    # Generates the HTML to render a paging control, if there is more than one page to be shown.
    #
    # @param [Array] collection List of content to be shown
    # @param [Cms::ContentType || Class] content_type The content type of the collection (used to generate links to Previous/Next)
    # @param [Hash] options
    def render_pagination(collection, content_type, options={})
      if collection.blank?
        content_tag(:div, "No Content", :class => "pagination")
      else
        model_class = content_type.instance_of?(Class) ? content_type : content_type.model_class
        render :partial => "cms/shared/pagination", :locals => {
            :collection => collection,
            :first_page_path => cms_connectable_path(model_class, {:page => 1}.merge(options)),
            :previous_page_path => cms_connectable_path(model_class, {:page => collection.previous_page ? collection.previous_page : 1}.merge(options)),
            :current_page_path => cms_connectable_path(model_class, options),
            :next_page_path => cms_connectable_path(model_class, {:page => collection.next_page ? collection.next_page : collection.current_page}.merge(options)),
            :last_page_path => cms_connectable_path(model_class, {:page => collection.total_pages}.merge(options))
        }
      end
    end

    def url_with_mode(url, mode)
      url = "" unless url # Handles cases where request.referrer is nil (see cms/_page_toolbar.html.erb for an example)
      uri = URI.parse(url)
      if uri.query =~ /mode=[^&]*/
        "#{uri.path}?#{uri.query.gsub(/((^|&)mode=)[^&]*/) { |s| "#{$1}#{mode}" }}"
      elsif uri.query
        "#{uri.path}?#{uri.query}&mode=#{mode}"
      else
        "#{uri.path}?mode=#{mode}"
      end
    end

    def determine_order(current_order, order)
      if current_order == order
        if order =~ / desc$/i
          order.sub(/ desc$/i, '')
        else
          order << ' desc'
        end
      else
        order
      end
    end

    # Render a CMS styled 'Edit' button. This button will appear on tool bars, typically set apart visually from other buttons.
    #
    # @param [Hash] options The options for this tag
    # @option options [Path] :path The path or URL to link_to. Takes same types at url_for or link_to. Defaults to '#' if not specified.
    # @option options [Boolean] :enabled If false, the button will be marked disabled. Default to false.
    def edit_button(options={bootstrap: false})

      label = options[:bootstrap]? "Edit" : span_tag("&nbsp;Edit&nbsp;".html_safe)
      classes = styles_for_button(options)
      classes << " disabled" if !options[:enabled]

      link_to_path = options[:path] ? options[:path] : "#"
      span_options = {:id => 'edit_button', :class => classes}
      link_to label, link_to_path, span_options

    end

    # Render a CMS styled 'Add' button. This button will appear on tool bars, typically set apart visually from other buttons.
    #
    # @param [Path] The path or URL to link_to. Takes same types at url_for or link_to.
    def add_button(path, options={bootstrap: false})
      classes = styles_for_button(options)
      label = options[:bootstrap]? "Add" : span_tag("&nbsp;Add&nbsp;".html_safe)
      span_options = {:class => classes}
      link_to label, path, span_options
    end

    private

    def styles_for_button(options)
      options[:bootstrap] ? "btn btn-primary pull-left": "button"
    end
    # Converts a CSS jQuery selector into something that can be suitably used as a CSS id element.
    def to_id(selector, suffix=nil)
      id = selector.gsub(".", "_")
      id = id + "_#{suffix}" if suffix
      id
    end
  end
end
