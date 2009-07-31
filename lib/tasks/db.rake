require 'find'

namespace :db do
  namespace :fixtures do
    desc 'Dumps all models into fixtures.'
    task :dump => :environment do
      models = []
      Find.find(RAILS_ROOT + '/app/models') do |path|
        unless File.directory?(path) then models << path.match(/(\w+).rb/)[1] end
      end
  
      models -= %w[content_observer guest_user file_block image_block email_message_mailer]
  
      puts "Models: " + models.join(', ')
      
      models.each do |m|
        model = m.classify.constantize
        create_fixture(model)
        create_fixture(model.version_class) if model.versioned?
      end
    end
    
    def create_fixture(model)
      puts "Creating fixture for #{model.table_name}"
      entries = model.find(:all, :order => 'id ASC')
      
      formatted, increment, tab = '', 1, '  '
      entries.each do |a|
        formatted += model.table_name.singularize + '_' + increment.to_s + ':' + "\n"
        increment += 1
        
        a.attributes.each do |column, value|
          formatted += tab
          
          match = value.to_s.match(/\n/)
          if match
            formatted += column + ': |' + "\n"
            
            value.to_a.each do |v|
              formatted += tab + tab + v
            end
          else
            formatted += column + ': ' + value.to_s
          end
          
          formatted += "\n"
        end
                  
        formatted += "\n"
      end
    
      model_file = RAILS_ROOT + '/test/fixtures/' + model.table_name + '.yml'
      
      # Final munging of file
      formatted = "# auto-generated by rake db:fixtures:dump, DO NOT EDIT BY HAND!\n#{formatted}"
      
      # Scrub ERB
      formatted.gsub!('<% ', ',<%% ')
      formatted.gsub!('<%= ', ',<%%= ')
      formatted.gsub!(' %>', ' %%>')
      
      File.exists?(model_file) ? File.delete(model_file) : nil
      File.open(model_file, 'w') {|f| f << formatted}      
    end
    
  end
end
