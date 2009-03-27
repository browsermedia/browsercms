class BrowserCmsDemoSiteGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      # Copy all public files
      Dir["#{File.dirname(__FILE__)}/templates/public/**/*"].each do |f|
        if File.file?(f)
          file_name = f.sub(/^#{File.dirname(__FILE__)}\/templates\//,'')
          m.directory File.dirname(file_name)
          m.file file_name, file_name
        end
      end
      
      m.migration_template 'migration.rb', 'db/migrate', :assigns => {
        :page_templates => page_templates,
        :page_partials => page_partials
      }, :migration_file_name => "load_demo_site_data"
      
    end
  end
  
  # Returns an array of strings that are ruby code.
  # Each string is a hash that should be passed to the create_page_template method
  # in the migration
  def page_templates
    Dir["#{File.dirname(__FILE__)}/templates/page_templates/*.erb"].map do |f|
      name, format, handler = File.basename(f).split('.')
      %Q{create_page_template(:#{name}, 
        :name => "#{name}", :format => "#{format}", :handler => "#{handler}", 
        :body => <<-HTML
#{open(f){|f| f.read}}
      HTML
      )}
    end
  end
  
  def page_partials
    Dir["#{File.dirname(__FILE__)}/templates/page_partials/*.erb"].map do |f|
      name, format, handler = File.basename(f).split('.')
      %Q{create_page_partial(:#{name}, 
        :name => "#{name}", :format => "#{format}", :handler => "#{handler}", 
        :body => <<-HTML
#{open(f){|f| f.read}}
      HTML
      )}
    end
  end
  
end