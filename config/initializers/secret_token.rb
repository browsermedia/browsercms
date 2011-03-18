# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
if defined?(Browsercms)
  Browsercms::Application.config.secret_token = '6a8de9165513928d69cc3b7144d8c76c65d14aa73f7458660185ef2a812a4251cbd72cecce388f691978f25ca25e923c086edbcb0812ac39301ba6da5bfb5f0b'
end