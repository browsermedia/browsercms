class DeviseCreateUsers < ActiveRecord::Migration
  def change
    change_table(:cms_users) do |t|
      ## Database authenticatable
      #t.string :email,              :null => false, :default => ""
      t.string :encrypted_password, :null => false, :default => ""

      ## Recoverable
      t.rename   :reset_token, :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.rename :remember_token_expires_at, :remember_created_at
      t.remove :remember_token # Not needed by devise.

      # Remove old SHA based encrypted passwords.
      # Comment out the following line if you have a strong need to preserve old hashed passwords
      t.remove :crypted_password

      ## Trackable
      #t.integer  :sign_in_count, :default => 0, :null => false
      #t.datetime :current_sign_in_at
      #t.datetime :last_sign_in_at
      #t.string   :current_sign_in_ip
      #t.string   :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, :default => 0, :null => false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at


      #t.timestamps
    end

    add_index :cms_users, :email,                :unique => true
    add_index :cms_users, :reset_password_token, :unique => true
    # add_index :users, :confirmation_token,   :unique => true
    # add_index :users, :unlock_token,         :unique => true
  end
end
