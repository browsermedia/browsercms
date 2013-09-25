class CreateFormEntries < ActiveRecord::Migration
  def change
    create_table :cms_form_entries do |t|
      t.text :data_columns
      t.integer :form_id
      t.timestamps
    end
  end
end
