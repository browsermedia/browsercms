class CreateEmailMessages < ActiveRecord::Migration
  def self.up
    create_table :email_messages do |t|
      t.string :sender
      t.text :recipients
      t.text :subject
      t.text :cc
      t.text :bcc
      t.text :body
      t.string :content_type
      t.datetime :delivered_at

      t.timestamps
    end
  end

  def self.down
    drop_table :email_messages
  end
end
