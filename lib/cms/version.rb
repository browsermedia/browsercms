##
# Allows the precise version of BrowserCMS to be determined programatically.
#
module Cms
  VERSION = "5.0.2.rc1"

  # Return the current version of the CMS.
  def self.version
    VERSION
  end
end
