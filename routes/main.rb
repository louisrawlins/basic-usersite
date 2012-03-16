get '/' do  
  redirect GlobalSettings.default_user_home, 303 if current_user
  current_user
  erb :main
end


get '/login' do
  current_user
  erb :'auth/login_page'
end

post '/login' do
  if user = User.authenticate(params[:email], params[:password])
    session[:user] = user.id
    flash[:notice] = GlobalSettings.flash_successful_login(user)
    #redirect_to_stored
    redirect GlobalSettings.default_user_home, 303
  else
    flash[:login_error] = GlobalSettings.flash_failed_login
    redirect '/login', 303
  end
end

get '/logout' do
  session[:user] = nil
  flash[:notice] = GlobalSettings.flash_logout
  redirect '/', 303
end

get '/signup' do
  redirect GlobalSettings.default_user_home, 303 if current_user

  erb :'auth/signup'
end

post '/signup' do
  @user = User.new({
    :email                 => params[:email],
    :email_confirmation    => params[:email_confirmation],
    :password              => params[:password],
    :password_confirmation => params[:password_confirmation],
    :firstname             => params[:firstname],
    :lastname              => params[:lastname]
  })

  if @user.save
    session[:user] = @user.id
    redirect GlobalSettings.default_user_home, 303
  else
    logger.error "Can't create user:"
    logger.error @user.errors
    flash[:error] = GlobalSettings.flash_user_create_failed
    redirect '/signup', 303
  end
end

get '/firstlogin' do
  if current_user
    erb :'auth/first_login'
  else
    redirect '/login', 303
  end
end

post '/firstlogin' do
  user = current_user
  
  if user
    if user.update({ :password => params[:password],
                     :password_confirmation => params[:password_confirmation],
                     :first_login => false })
      redirect GlobalSettings.default_user_home, 303
    else
      flash[:error] = GlobalSettings.flash_update_password_failed
      redirect '/firstlogin', 303
    end
  else
    redirect '/login', 303
  end
end
