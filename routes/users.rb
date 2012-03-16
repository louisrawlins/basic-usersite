get '/home' do
  login_required

  erb :home_user
end

get '/profile' do
  login_required
  
  erb :profile
end

post '/profile' do
  login_required
  
  if current_user.update(params['user'])
    flash[:notice] = GlobalSettings.flash_profile_update_success
    redirect '/profile', 303
  else
    flash[:error] = GlobalSettings.flash_profile_update_failed
    erb :profile
  end
end



