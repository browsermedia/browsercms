class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.integer :assigned_by_id
      t.integer :assigned_to_id
      t.integer :page_id
      t.text :comment
      t.date :due_date
      t.datetime :completed_at

      t.timestamps
    end
  end

  def self.down
    drop_table :tasks
  end
end
