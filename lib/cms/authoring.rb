module Cms::Authoring

  # Represents the common permissions that are common for CMS operations.
  PERMISSIONS = [:edit_content, :administrate, :publish_content]

  # A full fledged editor can do these things.
  EDITOR_PERMISSIONS = [:edit_content, :publish_content]

end