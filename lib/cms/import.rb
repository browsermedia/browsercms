require File.join(File.dirname(__FILE__), "..", "..", "config", "environment")

class Cms::Import < ActiveRecord::Base
  class << self
        
    def import(options={})
      connect options[:connection]
      load_users
      load_sections
    end
    
    def connect(options={})
      establish_connection({
        :adapter  => "mysql",
        :host     => "localhost"
      }.merge(options || {}))
    end
    
    def load_users
      select_all("select * from users").each do |user|
        u = User.new(:login => user["username"], :email => user["email_address"], :password => user["password"], :password_confirmation => user["password"])
        u.id = user["id"].to_i
        u.save!
        puts "Created user #{u.id} #{u.login}"
      end
    end
    
    def load_sections
      select_all("select * from sections order by parent_section_id").each do |section|
        sec = Section.new(
          :name => section["name"], 
          :parent_id => section["parent_section_id"]
        )
        sec.id = section["id"].to_i
        sec.save!
        puts "Created user #{sec.id} #{sec.name}"
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