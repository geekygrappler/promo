class RegistrationsController < Devise::RegistrationsController
  def new
    super
  end

  def create
    build_resource(sign_up_params)
    resource.save
    if resource.persisted?
      # sign_up(resource_name, resource)
      data = {
        token: resource.authentication_token,
        email: resource.email
      }
      render json: data, status: 201 and return
    end
  end

  def update
    super
  end
end