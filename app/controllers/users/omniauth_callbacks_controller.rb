class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def keycloak
    from_omniauth :keycloak
  end

  # TODO: regression test login with facebook to make sure it still works
  # (or just tear it out, it was commented out anyway)
  def facebook
    from_omniauth :facebook
  end

  private

  def from_omniauth(provider)
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: provider.humanize) if is_navigational_format?
    else
      session["devise.#{provider}_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end
end
