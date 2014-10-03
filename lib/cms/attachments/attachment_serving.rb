module Cms
  module Attachments

    # Can be added to Controllers to handle serving files.
    module Serving

      # Send the file if:
      #   1. It exists:
      #   2. The user has permissions to see it.
      #
      # The strategy used to send the file can be configured based on the config.cms.attachments.storage parameter.
      # Default is:
      #   storage = :filesystem -> Cms::Attachments::FilesystemStrategy
      def send_attachment(attachment)
        if attachment
          raise Cms::Errors::AccessDenied unless current_user.able_to_view?(attachment)
          strategy_class = send_attachments_with
          strategy_class.send_attachment(attachment, self)
        end
      end

      def send_attachments_with
        Cms::Attachments::Serving.send_attachments_with
      end

      # @return [#send_attachments] The strategy that will be used to serve files.
      def self.send_attachments_with
        storage = Rails.configuration.cms.attachments.storage
        "Cms::Attachments::#{storage.to_s.classify}Strategy".constantize
      end

    end

    class FilesystemStrategy
      
      def self.file_cache_directory
        Rails.configuration.cms.attachments.file_cache_directory
      end
      
      
      def self.attachments_storage_location
        Rails.configuration.cms.attachments.storage_directory
      end

      def self.send_attachment(attachment, controller)
        style = controller.params[:style]
        style = "original" unless style
        path_to_file = attachment.path(style)
        if File.exists?(path_to_file)
          copy_file_to_cache(path_to_file, attachment.data_file_path)
          Rails.logger.debug "Sending file #{path_to_file}"
          controller.send_file(path_to_file,
                               :filename => attachment.file_name,
                               :type => attachment.file_type,
                               :disposition => "inline"
          )
        else
          msg = "Couldn't find file #{path_to_file}'"
          Rails.logger.error msg
          raise ActiveRecord::RecordNotFound.new(msg)
        end
      end
    
      def self.copy_file_to_cache(file_path, cache_path)
        if file_cache_directory
          cache_path = File.join(file_cache_directory, cache_path)
          #remove the filename so we can do a mkdir -p
          unless File.exists?(cache_path)
            dir_path = cache_path.split("/")[1..-2].join("/")
            FileUtils.mkdir_p(File.join("/", dir_path))
            FileUtils.cp(file_path, cache_path)
            FileUtils.chmod(0644, cache_path)
          end  
        end
      end
      
    end
  end
end