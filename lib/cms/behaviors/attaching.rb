module Cms
  module Behaviors
    module Attaching
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
          belongs_to :attachment   
          
          validates_each :attachment_file do |record, attr, value|
            if record.attachment && !record.attachment.valid?
              record.attachment.errors.each do |err_field, err_value|
                if err_field.to_sym == :file_name
                  record.errors.add(:attachment_file_name, err_value)
                else  
                  record.errors.add(:attachment_file, err_value)
                end
              end      
            end
          end       
        end
        module InstanceMethods

          def attachment_file
            @attachment_file ||= attachment ? attachment.file : nil
          end

          def attachment_file=(file)
            @attachment_file = file
          end

          def attachment_file_name
            @attachment_file_name ||= attachment ? attachment.file_name : nil
          end

          def attachment_file_name=(file_name)
            @attachment_file_name = sanitize_file_name(file_name)
          end

          def attachment_section_id
            @attachment_section_id ||= attachment ? attachment.section_id : nil
          end

          def attachment_section_id=(section_id)
            @attachment_section_id = section_id
          end

          def attachment_section
            @attachment_section ||= attachment ? attachment.section : nil
          end

          def attachment_section=(section)
            @attachment_section_id = section ? section.id : nil
            @attachment_section = section
          end

          def process_attachment
            if attachment.nil? && attachment_file.blank?
              unless attachment_file_name.blank?
                errors.add(:attachment_file, "You must upload a file")
                return false
              end
              unless attachment_section_id.blank?
                errors.add(:attachment_file, "You must upload a file")
                return false
              end              
            else
              build_attachment if attachment.nil?  
              attachment.file = attachment_file 
              set_attachment_file_name
              if attachment_file_name.blank?
                errors.add(:attachment_file_name, "File Name is required for attachment")
                return false
              end
              set_attachment_section
              if attachment_section_id.blank?
                errors.add(:attachment_file, "Section is required for attachment")
                return false
              end
            end
          end

          def clear_attachment_ivars
            @attachment_file = nil
            @attachment_file_name = nil
            @attachment_section_id = nil
            @attachment_section = nil            
          end

          # Override this method if you would like to override the way file_name is set
          def set_attachment_file_name
            attachment.file_name = @attachment_file_name if @attachment_file_name
          end

          # Override this method if you would like to override the way the section is set
          def set_attachment_section
            attachment.section_id = @attachment_section_id if @attachment_section_id
          end

          def sanitize_file_name(file_name)
            file_name.to_s.gsub(/\s/,'_').gsub(/[&+()]/,'-').gsub(/[=?!'"{}\[\]#<>%]/, '')
          end

          def update_attachment_if_changed
            if attachment
              attachment.archived = archived if self.class.archivable?
              attachment.published = !!(publish_on_save) if self.class.publishable?
              attachment.save if new_record? || attachment.changed? || attachment.file
              self.attachment_version = attachment.version
            end
          end

          #Size in kilobytes
          def file_size
            attachment ? "%0.2f" % (attachment.file_size / 1024.0) : "?"
          end

          def after_as_of_version
            self.attachment = Attachment.find(attachment_id).as_of_version(attachment_version)
          end

          def attachment_path
            attachment ? attachment.file_name : nil   
          end

          def attachment_link
            if attachment
              live? ? attachment_path : "/cms/attachments/show/#{attachment_id}?version=#{attachment_version}"    
            else
              nil
            end  
          end
        end
      end
    end
  end
end