class CreateDeprecatedInputs < ActiveRecord::Migration
  def change
    create_content_table :deprecated_inputs do |t|
      t.string :name
      t.text :content, :size => (64.kilobytes + 1)
      t.text :template, :size => (64.kilobytes + 1)
      t.string :template_handler
      t.belongs_to :category
      t.timestamps
    end
  end
end
