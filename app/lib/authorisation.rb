module Authorisation
  def set_user_from_access_token
    # TODO this is nasty, if we're hitting public API from our own web client, we won't have
    # an API key, we'll have devise token belongs to the current user
    if current_user
      @user = current_user and return
    end
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