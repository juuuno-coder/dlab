class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  protect_from_forgery except: :google_oauth2
  skip_before_action :verify_authenticity_token, only: :google_oauth2
  def google_oauth2
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: 'Google'
      sign_in_and_redirect @user, event: :authentication
    else
      session['devise.google_data'] = request.env['omniauth.auth'].except('extra')
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    end
  end

  def failure
    redirect_to root_path, alert: "로그인에 실패하였습니다."
  end
end
