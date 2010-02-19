# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key    => '_browsercms_session',
  :secret => 'ffa62e83f02917fa3ebebe6383f2331e34a82971babc98e8163e12287b5db5c13e6651db9cea2b04ceeb34a25ed8cf7f67e41f9701f0588b11718f05c9c30848'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
