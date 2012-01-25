# TODO: Can be removed after updating to rack 1.3.0
# Avoids this issue: http://stackoverflow.com/questions/3622394/ruby-1-9-2-strange-warning-when-running-cucumber-specs
module Rack
  module Utils
    def escape(s)
      CGI.escape(s.to_s)
    end
    def unescape(s)
      CGI.unescape(s)
    end
  end
end