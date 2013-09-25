class CreateFormFields < ActiveRecord::Migration
  def change
    create_table :cms_form_fields do |t|
      t.integer :form_id
      t.string :label
      t.string :name
      t.string :field_type
      t.boolean :required
      t.integer :position
      t.text :instructions
      t.text :default_value
      t.timestamps
    end

    # Field names should be unique per form
    add_index :cms_form_fields, [:form_id, :name], :unique => true
  end
end
