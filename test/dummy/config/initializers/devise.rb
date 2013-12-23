# Just for the BrowserCMS application
Devise.setup do |config|

  # The secret key used by Devise. Devise uses this key to generate
  # random tokens. Changing this key will render invalid all existing
  # confirmation, reset password and unlock tokens in the database.
  config.secret_key = '938e4b2eece284c45788890c670cf4bfa61f281fe8b8f42dda662973017b8271fa61398c32e71107e8d779b1477d6434907a0ec8ee150f7c933d1f6f7d7c4de9'

  # Add test_password strategy BEFORE other CMS authentication strategies
  config.warden do |manager|
    manager.default_strategies(:scope => :cms_user).unshift :test_password
  end
end



