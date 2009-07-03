module Cms
  class << self
    __root__ = File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))

    define_method(:root) { __root__ }

    ::SPEC = eval(File.read(__root__ + '/browsercms.gemspec'))

    attr_accessor :attachment_file_permission

    def version
      @version = SPEC.version.version
    end
    
    def build_number; 252 end
    
    def load_rake_tasks
      load "#{Cms.root}/lib/tasks/cms.rake"
    end

    # This is called after the environment is ready
    def init
      ActionController::Routing::RouteSet::Mapper.send :include, Cms::Routes
      ActiveSupport::Dependencies.load_paths += %W( #{RAILS_ROOT}/app/portlets )
      ActiveSupport::Dependencies.load_paths += %W( #{RAILS_ROOT}/app/portlets/helpers )      
      ActionController::Base.append_view_path DynamicView.base_path
      ActionView::Base.default_form_builder = Cms::FormBuilder
      
      # This is jsut to be safe
      # dynamic views are stored in a tmp dir
      # so they could be blown away on a server restart or something
      # so this just makes sure they get written out
      DynamicView.write_all_to_disk! if DynamicView.table_exists?
    end
    
    # This is used by CMS modules to register with the CMS generator
    # which files should be copied over to the app when the CMS generator is run.
    # src_root is the absolute path to the root of the files,
    # then each argument after that is a Dir.glob pattern string.
    def add_generator_paths(src_root, *files)
      generator_paths << [src_root, files]
    end
    
    def generator_paths
      @generator_paths ||= []
    end   
    
    def add_to_rails_paths(path)
      ActiveSupport::Dependencies.load_paths << File.join(path, "app", "portlets")
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

ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(
	:year_month_day => '%Y/%m/%d',
	:date => '%m/%d/%Y'	
)

Cms.add_generator_paths(Cms.root, 
  "public/javascripts/jquery*",
  "public/javascripts/cms/**/*",
  "public/fckeditor/**/*",
  "public/site/**/*",   
  "public/stylesheets/cms/**/*",
  "public/images/cms/**/*",
  "db/migrate/[0-9]*_*.rb")
