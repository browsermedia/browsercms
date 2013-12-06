class KillResetPassword < ActiveRecord::Migration
  def up
    Cms::Portlet.connection.execute("UPDATE cms_portlets SET type = 'DeprecatedPlaceholder' WHERE type = 'ResetPasswordPortlet'")
  end
end
