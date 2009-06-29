class ContentBlockGenerator < Rails::Generator::NamedBase
  default_options :skip_timestamps => false, :skip_migration => false

  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions class_path, class_name

      # Create the content block
      m.directory File.join('app/models')
      m.template 'content_block.rb', File.join('app/models', "#{file_name}.rb")

      # Create the unit test for the model
      m.directory File.join('test/unit/models')
      m.template 'unit_test.erb', File.join('test/unit/models', "#{file_name}_test.rb")
      
      # Create the controller
      m.directory File.join('app/controllers/cms')
      m.template 'controller.rb', File.join('app/controllers/cms', "#{file_name.pluralize}_controller.rb")

      # Create the edit form for the content type
      m.directory File.join('app/views/cms/', file_name.pluralize)
      m.template '_form.html.erb', File.join('app/views/cms/', file_name.pluralize, "_form.html.erb")
      m.template 'render.html.erb', File.join('app/views/cms/', file_name.pluralize, "render.html.erb")

      # Create functional test for the controller
      m.directory File.join('test/functional/cms/')
      m.template 'functional_test.erb', File.join('test/functional/cms/', "#{file_name.pluralize}_controller_test.rb")

      # Create the routes for the content block
      logger.route "map.content_blocks :#{file_name.pluralize}"
      sentinel = 'ActionController::Routing::Routes.draw do |map|'
      m.gsub_file 'config/routes.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
        "#{match}\n  map.namespace('cms') {|cms| cms.content_blocks :#{file_name.pluralize} }\n"
      end

      unless options[:skip_migration]
        m.migration_template 'migration.rb', 'db/migrate', :assigns => {
          :migration_name => "Create#{class_name.pluralize.gsub(/::/, '')}",
        }, :migration_file_name => "create_#{file_path.gsub(/\//, '_').pluralize}"
      end
    end
  end

  protected
    def banner
      "Usage: #{$0} #{spec.name} ModelName [field:type, field:type]"
    end

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--skip-migration", 
             "Don't generate a migration file for this model") { |v| options[:skip_migration] = v }
    end
    
    def route_countent_block(name)
      resource_list = resources.map { |r| r.to_sym.inspect }.join(', ')
      sentinel = 'ActionController::Routing::Routes.draw do |map|'

      logger.route "map.resources #{resource_list}"
      unless options[:pretend]
        gsub_file 'config/routes.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
          "#{match}\n  map.resources #{resource_list}\n"
        end
      end
    end
    
end
