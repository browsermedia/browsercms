class AddChoices < ActiveRecord::Migration
  def change
    add_column prefix(:form_fields), :choices, :text
  end
end
