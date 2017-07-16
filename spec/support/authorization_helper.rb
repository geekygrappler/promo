module TestAuthorisation
  def authorisation_header
    user = User.create(email: 'test@test.com')
    api_key = ApiKey.create(user: user)
    {'Authorization': api_key.access_token}
  end
end