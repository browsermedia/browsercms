module Cms
  module Behaviors
    module Attaching
      SANITIZATION_REGEXES = [ [/\s/, '_'], [/[&+()]/, '-'], [/[=?!'"{}\[\]#<>%]/, ''] ]
      
      def self.included(model_class)
        model_class.extend(MacroMethods)
      end
      module MacroMethods      
        def belongs_to_attachment?
          !!@belongs_to_attachment
        end
        def belongs_to_attachment(options={})
          @belongs_to_attachment = true
          include InstanceMethods
          before_validation :process_attachment  
          before_save :update_attachment_if_changed
          after_save :clear_attachment_ivars
          belongs_to :attachment, :dependent => :destroy 
          
          validates_each :attachment_file do |record, attr, value|
            if record.attachment && !record.attachment.valid?
              record.attachment.errors.each do |err_field, err_value|
                if err_field.to_sym == :file_path
                  record.errors.add(:attachment_file_path, err_value)
                else  
                  record.errors.add(:attachment_file, err_value)
                end
              end      
            end
          end       
        end
      end
      module InstanceMethods

        def attachment_file
          @attachment_file ||= attachment ? attachment.temp_file : nil
        end

        def attachment_file=(file)
          if @attachment_file != file
            dirty!
            @attachment_file = file
          end
        end

        def attachment_file_name
          @attachment_file_name ||= attachment ? attachment.file_name : nil
        end

        def attachment_file_path
          @attachment_file_path ||= attachment ? attachment.file_path : nil
        end

        def attachment_file_path=(file_path)
          fp = sanitize_file_path(file_path)
          if @attachment_file_path != fp
            dirty!
            @attachment_file_path = fp
          end
        end

        def attachment_section_id
          @attachment_section_id ||= attachment ? attachment.section_id : nil
        end

        def attachment_section_id=(section_id)
          if @attachment_section_id != section_id
            dirty!
            @attachment_section_id = section_id
          end
        end

        def attachment_section
          @attachment_section ||= attachment ? attachment.section : nil
        end

        def attachment_section=(section)
          if @attachment_section != section
            dirty!
            @attachment_section_id = section ? section.id : nil
            @attachment_section = section
          end
        end

        def process_attachment
          if attachment.nil? && attachment_file.blank?
            unless attachment_file_path.blank?
              errors.add(:attachment_file, "You must upload a file")
              return false
            end
            unless attachment_section_id.blank?
              errors.add(:attachment_file, "You must upload a file")
              return false
            end              
          else
            build_attachment if attachment.nil?  
            attachment.temp_file = attachment_file 
            set_attachment_file_path
            if attachment.file_path.blank?
              errors.add(:attachment_file_path, "File Name is required for attachment")
              return false
            end
            set_attachment_section
            if attachment.section_id.blank?
              errors.add(:attachment_file, "Section is required for attachment")
              return false
            end
          end
        end

        def clear_attachment_ivars
          @attachment_file = nil
          @attachment_file_path = nil
          @attachment_section_id = nil
          @attachment_section = nil            
        end

        # Override this method if you would like to override the way the section is set
        def set_attachment_section
          if new_record? && !attachment_file.blank?
            attachment.section = Section.root.first
          end
        end

        # Override this method if you would like to override the way file_path is set
        def set_attachment_file_path
          if new_record? && !attachment_file.blank?
            attachment.file_path = "/attachments/#{File.basename(attachment_file.original_filename).to_s.downcase}"
          end
        end

        def sanitize_file_path(file_path)
          SANITIZATION_REGEXES.inject(file_path.to_s) do |s, (regex, replace)|
            s.gsub(regex, replace)
          end
        end

        def update_attachment_if_changed
          if attachment
            attachment.archived = archived if self.class.archivable?
            if respond_to?(:revert_to_version) && revert_to_version
              attachment.revert_to(revert_to_version.attachment_version)
            elsif new_record? || attachment.changed? || attachment.temp_file
              attachment.save
            end
            self.attachment_version = attachment.draft.version
          end
        end

        def after_publish
          attachment.publish if attachment
        end

        #Size in kilobytes
        def file_size
          attachment ? "%0.2f" % (attachment.file_size / 1024.0) : "?"
        end

        def after_as_of_version
          if attachment_id && attachment_version
            self.attachment = Attachment.find(attachment_id).as_of_version(attachment_version)
          end
        end

        def attachment_link
          if attachment
            (published? && live_version?) ? attachment_file_path : "/cms/attachments/#{attachment_id}?version=#{attachment_version}"
          else
            nil
          end  
        end
        
        # Forces this record to be changed, even if nothing has changed
        # This is necessary if just the section.id has changed, for example
        def dirty!
          # Seems like a hack, is there a better way?
          self.updated_at = Time.now
        end          
        
      end
    end
  end
end