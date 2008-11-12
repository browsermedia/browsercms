class ContentBlockGenerator < Rails::Generator::NamedBase
  default_options :skip_timestamps => false, :skip_migration => false

  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions class_path, class_name

      # Create the models directory if we need to
      m.directory File.join('app/models', class_path)

      # Create the content block
      m.template 'content_block.rb', File.join('app/models', class_path, "#{file_name}.rb")

      # Create the edit form for the content type
      m.directory File.join('app/views/cms/', file_name.pluralize)
      m.template '_form.html.erb', File.join('app/views/cms/', file_name.pluralize, "_form.html.erb")

      unless options[:skip_migration]
        m.migration_template 'migration.rb', 'db/migrate', :assigns => {
          :migration_name => "Create#{class_name.pluralize.gsub(/::/, '')}"
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
end
