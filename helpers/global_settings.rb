
module GlobalSettings
  class << self; 
    attr_accessor :flash_failed_login, 
      :flash_logout, 
      :flash_user_create_failed,
      :flash_update_password_failed,
      :flash_profile_update_success,
      :flash_profile_update_failed,
      :password_reset_email_subject,
      :flash_change_password,
      :default_user_home #pages
      
  end
  #pages
  @default_user_home = '/home'
  
  
  #login process Settings
  @flash_failed_login = "Incorrect Email/Password Combination"
  @flash_logout = "Logout successful"
  
  def GlobalSettings.flash_successful_login(user)
    "Welcome, #{user.username}!"
  end
  
  
  
  #user creation
  @flash_user_create_failed ="Could not create new user"
  @flash_update_password_failed = 'Could not update user password'
  @flash_profile_update_success = 'Profile was updated successfully'
  @flash_profile_update_failed = 'Could not update profile'
  
  def GlobalSettings.flash_email_unknown(email)
    'Unknown email: #{email}'
  end  
  @password_reset_email_subject = "Basic User Site: password reset"
  
  @flash_change_password = 'Password differs with confirmation'
  
end
