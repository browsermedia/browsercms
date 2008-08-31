ActiveRecord::Schema.define :version => 0 do
  create_table :mixins, :force => true do |t|
    t.column :parent_id,    :integer
    t.column :pos,          :integer
    t.column :created_at,   :datetime
    t.column :updated_at,   :datetime
    t.column :lft,          :integer
    t.column :rgt,          :integer    
    t.column :root_id,      :integer
    t.column :type,         :string
  end
end
