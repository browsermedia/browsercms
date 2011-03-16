require 'cms/version'

module Cms
  class << self
    __root__ = File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))

    define_method(:root) { __root__ }

    attr_accessor :attachment_file_permission

    def version
      @version = Cms::VERSION
    end
    
    def build_number; 252 end
    
    def load_rake_tasks
      load "#{Cms.root}/lib/tasks/cms.rake"
    end

    # This is called after the environment is ready
    # This all needs to be moved to the Engine
    def init
      puts "BrowserCMS init has been called!!!!!!!"

      # ToDo: This is how we are adding new methods to the routes.rb file. Rails 3 might provide more direct way.
     # ActionDispatch::Routing::Mapper.send :include, Cms::Routes

      #need to add gem's app directories to the load path - 
      #the list is taken from what rails has automagically added to $: for the Rails.root dirs
#      ActiveSupport::Dependencies.autoload_paths += %W( #{self.root}/vendor #{self.root}/app/mailers #{self.root}/app/helpers)
#      ActiveSupport::Dependencies.autoload_paths += %W( #{self.root}/app/controllers #{self.root}/app/models #{self.root}/app/portlets)
#      ActiveSupport::Dependencies.autoload_paths += %W( #{Rails.root}/app/portlets )
#      ActiveSupport::Dependencies.autoload_paths += %W( #{Rails.root}/app/portlets/helpers )
#      ActionController::Base.append_view_path DynamicView.base_path
#      ActionController::Base.append_view_path %W( #{self.root}/app/views)

#      ActionView::Base.default_form_builder = Cms::FormBuilder
      
      # ActiveRecord JDBC adapter depends on no database connection having
      # been established to work properly.
#      require 'jdbc_adapter' if defined?(JRUBY_VERSION)
      
      # This is just to be safe
      # dynamic views are stored in a tmp dir
      # so they could be blown away on a server restart or something
      # so this just makes sure they get written out

      # Commenting out, as the app/model files don't seem to have been loaded yet at this point, so
      # we are getting class errors w/ STI.

#      DynamicView.write_all_to_disk! if DynamicView.table_exists?
    end
    
    # This is used by CMS modules to register with the CMS generator
    # which files should be copied over to the app when the CMS generator is run.
    # src_root is the absolute path to the root of the files,
    # then each argument after that is a Dir.glob pattern string.
    #
    # @param [String] src_root The root directory of the gem
    # @param [Array of String] files A list of all file names to be copied
    def add_generator_paths(src_root, *files)
      generator_paths << [src_root, files]
    end

    alias_method :add_paths_to_copied_into_project, :add_generator_paths

    def generator_paths
      @generator_paths ||= []
    end   
    
    def add_to_rails_paths(path)
      ActiveSupport::Dependencies.autoload_paths << File.join(path, "app", "portlets")
    end

    def add_to_routes(route)
      routes << route
    end
    def routes
      @routes ||=[]
    end

    def wysiwig_js
      @wysiwig_js ||= ['/bcms/ckeditor/ckeditor.js', '/bcms/ckeditor/editor.js']
    end

    def wysiwig_js=(path_array)
      @wysiwig_js = path_array
    end
    
    def markdown?
      Object.const_defined?("Markdown")
    end
    
    def reserved_paths
      @reserved_paths ||= ["/cms", "/cache"]
    end
    
    # This next 'hack' is to allow script/generate browser_cms to work on Windows machines. I'm not sure why this is necessary.
    #
    # This Generator is adding an absolute file path to the manifest, which is file (like a .js or migration) in
    # the gem directory on the developers's machine, rather
    # than just a relative path with the rails_generator directory. On windows, this will mean you are basically doing this.
    #
    # m.file "C:/Ruby/lib/ruby/gems/1.8/gems/browsercms-3.0.0/public/javascripts/jquery-ui.js", "testing/jquery-ui.js"
    #
    # When the generator hits this command during playback, it will throw an error like this:
    #   Pattern 'c' matches more than one generator: content_block, controller
    # The generator then fails and stops copying. Stripping the C: off the front seems to fix this problem.
    # I.e. This command correctly copies the file on Windows XP.
    #   m.file "/Ruby/lib/ruby/gems/1.8/gems/browsercms-3.0.0/public/javascripts/jquery-ui.js", "testing/jquery-ui.js"
    #
    def scrub_path(path)
      windows_drive_pattern =  /\b[A-Za-z]:\//    # Works on drives labeled A-Z:
      scrubbed_source_file_name = path.gsub(windows_drive_pattern, "/")
    end
  end
  module Errors
    class AccessDenied < StandardError
      def initialize
        super("Access Denied")
      end
    end
  end
end

Time::DATE_FORMATS.merge!(
	:year_month_day => '%Y/%m/%d',
	:date => '%m/%d/%Y'	
)


