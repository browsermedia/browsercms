module Cms

  # Can be added to Controllers to handle serving files.
  module AttachmentServing

    # Send the file if:
    #   1. It exists:
    #   2. The user has permissions to see it.
    def send_attachment(attachment)
      if attachment
        raise Cms::Errors::AccessDenied unless current_user.able_to_view?(attachment)

        #Construct a path to where this file would be if it were cached
        path_to_file = attachment.full_file_location

        if File.exists?(path_to_file)
          logger.warn "Sending file #{path_to_file}"
          send_file(path_to_file,
                    :filename => attachment.file_name,
                    :type => attachment.file_type,
                    :disposition => "inline"
          )
        end
      end
    end
  end
end