require File.join(File.dirname(__FILE__), "..", "..", "config", "environment")

#Meant to be called by rake task, for example:
# rake cms:import CMS_PATH=/Users/pbarry/perforce/depot/microbicide CMS_DB_NAME=microbicide
class Cms::Import < ActiveRecord::Base
  class << self        
    def import(options={})
      connect options[:connection]
      load_users
      load_sections
      load_page_templates
      load_pages
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
      copy_records(PageTemplate, "select * from page_templates",
        { :name => "name" },
        { :before_save => lambda{|record, row| 
            template_file = File.join(ENV['CMS_PATH'], "src", "webapp", row["template_view"])
            record.language = "erb"
            record.file_name = File.basename(template_file, ".jsp")
            record.body = convert_jsp_to_erb(open(template_file) {|f| f.read })
          }
        }
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
            
    private
      def connect(options={})
        establish_connection({
          :adapter  => "mysql",
          :host     => "localhost"
        }.merge(options || {}))
      end
    
      def select_all(sql)
        connection.select_all(sql)
      end

      def select_one(sql)
        connection.select_one(sql)
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
        
      #This is obviously a pretty ambitious task to try to attempt
      #I'm thinking we can just try to deal with low hanging fruit here  
      def convert_jsp_to_erb(content)
        s = content
        s.gsub!(/<page:container name="([^"]+)"\/>/) { "<%= container :#{$1} %>"}
        s.gsub!(/<%@\s*taglib[^%]*%>/, '')
        s.gsub!(/<jsp:include\s*page="([^"]*).jsp"\s*\/>/) { "<%= render :partial => '#{$1}' %>" }
        s.gsub!("<%= render :partial => '/site/inc/", "<%= render :partial => 'shared/")
        s.strip!
        s
      end  
        
  end
end