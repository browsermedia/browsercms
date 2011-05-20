require 'cms/version'

module Cms
  class << self
    __root__ = File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))

    define_method(:root) { __root__ }


    attr_accessor :attachment_file_permission

    def version
      @version = Cms::VERSION
    end

    def load_rake_tasks
      load "#{Cms.root}/lib/tasks/cms.rake"
    end

    # This is no longer really needed since Engines handle initialization.
    def init
      puts "BrowserCMS init has been called!!!!!!!"
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


