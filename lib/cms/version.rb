##
# Allows the precise version of BrowserCMS to be determined programatically.
#
module Cms
  VERSION = "4.2.8.rc1"

  # Return the current version of the CMS.
  def self.version
    VERSION
  end
end
