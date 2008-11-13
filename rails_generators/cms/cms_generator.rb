class CmsGenerator < Rails::Generator::Base
  def source_root
    Cms.root
  end
  def manifest
    record do |m|
      dirs = []
      [
        "public/javascript/jquery*", 
        "public/javascripts/cms/**/*", 
        "public/stylesheets/cms/**/*", 
        "public/images/cms/**/*", 
        "db/migrate/[0-9]*_*.rb"
      ].each do |d|
        Dir[File.join(Cms.root, d)].each do |f|
          if File.file?(f)
            dir = File.dirname(f.gsub("#{Cms.root}/",''))
            unless dirs.include?(dir)
              m.directory dir 
              dirs << dir
            end
            file = f.gsub("#{Cms.root}/", "")
            m.file file, file
          end
        end        
      end      
    end
  end
end