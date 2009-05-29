class BrowserCmsDemoSiteGenerator < Rails::Generator::Base
  
  def source_root
    "/"
  end
  
  def templates_dir(file=nil)
    f = File.expand_path(File.join(File.dirname(__FILE__), "templates", file))
    Cms.scrub_path(f)
  end
  
  def manifest
    record do |m|
      # Copy all public files
      Dir["#{Cms.root}/public/themes/blue_steel/**/*"].each do |f|
        if File.file?(f)
          file_name = f.sub("#{Cms.root}/", '')
          m.directory File.dirname(file_name)
          m.file Cms.scrub_path(f), file_name
        end
      end
      
      m.migration_template templates_dir('migration.rb'), 'db/migrate', :assigns => {
        :data => data,
        :page_templates => page_templates,
        :page_partials => page_partials
      }, :migration_file_name => "load_demo_site_data"
      
    end
  end
  
  def data
    open(File.join(Cms.root, "db", "demo", "data.rb")){|f| f.read}
  end
  
  # Returns an array of strings that are ruby code.
  # Each string is a hash that should be passed to the create_page_template method
  # in the migration
  def page_templates
    Dir["#{Cms.root}/db/demo/page_templates/*.erb"].map do |f|
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
    Dir["#{Cms.root}/db/demo/page_partials/*.erb"].map do |f|
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