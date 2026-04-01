# Link guest data to user after login/registration
Warden::Manager.after_set_user except: :fetch do |user, auth, opts|
  if user.is_a?(User)
    guest_id = auth.request.cookie_jar.signed[:guest_id]
    if guest_id
      Quote.where(guest_session_id: guest_id, user_id: nil).update_all(user_id: user.id)
    end
  end
end
