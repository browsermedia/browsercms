class CreateRegisteredBlock < ActiveRecord::Migration
  def self.up
    create_table :registered_blocks do |t|
      t.string :name
    end
    
    %w[HtmlBlock Portlet].each do |t|
      RegisteredBlock.create!(:name => t)
    end
    
  end

  def self.down
    drop_table :registered_blocks
  end
end
