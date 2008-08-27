class CreatePortletTypes < ActiveRecord::Migration
  def self.up
    create_table :portlet_types do |t|
      t.string :name
      t.text :form
      t.text :code
      t.text :template

      t.timestamps
    end
  end

  def self.down
    drop_table :portlet_types
  end
end
