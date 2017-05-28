module Authorisation
  def set_user_from_access_token
    api_key = ApiKey.find_by(access_token: request.headers['Authorization'])

    if api_key.nil?
      render json: {
          errors: {
              title: 'API key is not valid'
          }
      }, status: :unauthorized
    else
      @user = api_key.user
    end
  end
end