require 'email'

get '/forgot_pwd' do
  erb :'pwd_change/forgot_password'
end

post '/reset_pwd' do
  puts "reset password"
  email = params.delete 'email'

  user = User.first( :email => email )
  unless user
    flash[:error] = GlobalSettings.flash_email_unknown(email)
    return erb :'pwd_change/forgot_password'
  end
  
  pwd_change_request = PwdChangeRequest.new( user )
  pwd_change_request.save
  send_mail( :to => user.email,
             :subject => GlobalSettings.password_reset_email_subject,
             :html_body => erb( :'pwd_change/pwd_reset_email',
                                :layout => false,
                                :locals => {
                                  :token => pwd_change_request.token,
                                  :user => user
                                } ) )

  erb :'pwd_change/pwd_reset', :locals => { :email => email }
end

get '/pwd_change' do
  token = params.delete 'token'

  pwd_change_request = PwdChangeRequest.first( :token => token )

  return erb :'pwd_change/wrong_token' unless pwd_change_request
  return erb :'pwd_change/expired' if pwd_change_request.expires < Time.now

  session[:user] = pwd_change_request.user.id
  pwd_change_request.destroy

  redirect '/change_pwd'
end

get '/change_pwd' do
  current_user

  erb :'pwd_change/change_pwd'
end

post '/change_pwd' do
  user = current_user

  unless params[:password] == params[:password_confirmation]
    flash[:error] = GlobalSettings.flash_change_password
    return erb :'pwd_change/change_pwd'
  end

  user.password = params[:password]
  unless user.save
    flash[:error] = user.errors.inspect("") do |errstr,e|
      errstr + e.to_s
    end
    return erb :'pwd_change/change_pwd'
  end

  erb :'pwd_change/pwd_changed'
end
