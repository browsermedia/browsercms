# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :session_key => '_browsercms_session',
  :secret      => '641d4765c117b9d93e2134782f4ac81679bc37b83dae23ff8a49018c53e3c020f57b0b10180de8877c2d49f1b975bc42852ab5f8c35e0a0a81b8a9c37a78df6c'
}