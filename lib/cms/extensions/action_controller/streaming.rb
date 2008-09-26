#This monkey patch allows us to do send_filenot have a content disposition header
#see http://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/1120

module ActionController 
  module Streaming
    
    
    private
    def send_file_headers!(options)
      unless options[:disposition] == false
        disposition = options[:disposition].dup || 'attachment'
        disposition <<= %(; filename="#{options[:filename]}") if options[:filename]
        headers.update('Content-Disposition' => disposition)
      end

      options.update(DEFAULT_SEND_FILE_OPTIONS.merge(options))
      [:length, :type].each do |arg|
        raise ArgumentError, ":#{arg} option required" if options[arg].nil?
      end
      
      headers.update(
        'Content-Length'            => options[:length],
        'Content-Type'              => options[:type].to_s.strip,  # fixes a problem with extra '\r' with some browsers
        'Content-Transfer-Encoding' => 'binary'
      )

      # Fix a problem with IE 6.0 on opening downloaded files:
      # If Cache-Control: no-cache is set (which Rails does by default),
      # IE removes the file it just downloaded from its cache immediately
      # after it displays the "open/save" dialog, which means that if you
      # hit "open" the file isn't there anymore when the application that
      # is called for handling the download is run, so let's workaround that
      headers['Cache-Control'] = 'private' if headers['Cache-Control'] == 'no-cache'
    end
  end
end