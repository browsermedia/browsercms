require File.join(File.dirname(__FILE__), "..", "..", "config", "environment")

class Cms::Import < ActiveRecord::Base
  class << self        
    def import(options={})
      connect options[:connection]
      load_users
      load_sections
      load_page_templates
      load_pages
    end
    
    def connect(options={})
      establish_connection({
        :adapter  => "mysql",
        :host     => "localhost"
      }.merge(options || {}))
    end
    
    def load_users
      copy_records(User, "select * from users", 
        :login => "username",
        :email => "email_address",
        :password => "password",
        :password_confirmation => "password"
      )
    end
    
    def load_sections
      copy_records(Section, "select * from sections order by parent_section_id",
        :name => "name", 
        :parent_id => "parent_section_id"
      )
    end

    def load_page_templates
      #TODO: Obviously this will blow up because the template_view
      #Will not be an existing layout in the Rails app.
      #Idea: Specific the root of the CMS app
      #Have it read in the jsp file, do some simple search and replace maybe,
      #And store the file in the Rails app file system / database
      copy_records(PageTemplate, "select * from page_templates",
        :name => "name",
        :file_name => "template_view"
      )
    end
    
    def load_pages
      copy_records(Page, "select * from pages where current_version is null and page_status = 'PUBLISHED'", {
        :name => "name",
        :path => "custom_url",
        :status => "page_status",
        :section_id => "section_id",
        :template_id => "page_template_id"
      })
    end
      
    def copy_records(model, query, mapping, callbacks={})
      select_all(query).each do |row|
        record = model.new
        mapping.each do |attr, col|
          record.send("#{attr}=", row[col])
        end
        record.id = row["id"]
        callbacks[:before_save].call(record, row) if callbacks[:before_save]
        if record.save
          puts "Created #{model} #{record.id}"
        else
          raise "Could not save #{model} #{record.id}:\n - #{record.errors.full_messages.join("\n - ")}"
        end
        callbacks[:after_save].call(record, row) if callbacks[:after_save]
      end
    end
      
    private
      def select_all(sql)
        connection.select_all(sql)
      end

      def select_one(sql)
        connection.select_one(sql)
      end
        
  end
end