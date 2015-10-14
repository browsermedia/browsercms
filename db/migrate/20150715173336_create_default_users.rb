class CreateDefaultUsers < ActiveRecord::Migration
  def change
    create_table :cms_default_users do |t|
      t.column :login, :string
      t.column :full_name, :string
      t.column :extra_data, :text
      t.timestamps
    end

    add_index :cms_default_users, :login, unique: true
  end
end
