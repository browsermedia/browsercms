# For testing portlet behavior
module UsesHelperPortletHelper

  EXPECTED_CONTENT = "PortletHelper Output"
  def content_from_helper
    EXPECTED_CONTENT
  end
end
