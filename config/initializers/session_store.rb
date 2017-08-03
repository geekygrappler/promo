# Don't allow rails to set cookies, authentication only through tokens.
Rails.application.config.session_store :disabled
