#Once we gemify CMS, this stuff should go in rails/init.rb
require 'cms/extensions'

ActionController::Base.append_view_path "#{Rails.root}/tmp/views"

PageTemplate.all.each{|pt| pt.create_layout_file }
