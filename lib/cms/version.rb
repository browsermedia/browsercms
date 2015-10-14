##
# Allows the precise version of BrowserCMS to be determined programatically.
#
module Cms
  VERSION = '4.0.2'

  # Return the current version of the CMS.
  def self.version
    VERSION
  end
end
