class AddDraftVersionToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :latest_version, :integer

    # Will need to update all existing pages to have a valid value for this.
  end

  def self.down
    remove_column :pages, :latest_version
  end
end
