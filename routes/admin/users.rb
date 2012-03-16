require 'random_password'
require 'email'

get '/admin/users' do
  admin_required
  
  erb :'admin/users/index', :layout => :'admin/layout', :locals => { :users => User.all }
end

get '/admin/users/new' do
  admin_required
  
  erb :'admin/users/new', :layout => :'admin/layout', :locals => { :user => User.new }
end

get '/admin/user/:user_id/edit' do |user_id|
  admin_required
  
  user = User.get(user_id)
  if user
    erb :'admin/users/edit', :layout => :'admin/layout', :locals => { :user => user }
  else
    flash[:error] = "User not found."
    redirect '/admin/users', 303
  end
end

get '/admin/user/:user_id/destroy' do |user_id|
  admin_required
  
  user = User.get(user_id)
  if user
    if current_user == user
      flash[:error] = "You could not delete user you're working under."
    elsif user.destroy!
      flash[:notice] = "User was deleted."
    end
  else
    flash[:error] = "Could not delete user."
  end
  
  redirect '/admin/users', 303
end

get '/admin/user/:user_id/activate' do |user_id|
  admin_required

  user = User.get(user_id)
  if user
    if user.update!(:active => true)
      flash[:notice] = "User was activated."
    else
      flash[:error] = "Could not activate user."
    end
  else
    flash[:error] = "User not found."
  end

  redirect '/admin/users', 303
end

get '/admin/user/:user_id/deactivate' do |user_id|
  admin_required
  
  user = User.get(user_id)
  if user
    if user.update!(:active => false)
      flash[:notice] = "User was de-activated."
    else
      flash[:error] = "Could not de-activate user."
    end
  else
    flash[:error] = "User not found."
  end

  redirect '/admin/users', 303
end

post '/admin/users/create' do
  admin_required

  send_mail     = params.delete('send_mail')
  
  isins = params['user'].delete('allowed_companies')
  if params['user']['usertype'] == 'member' and
     not (isins.nil? or isins.empty?)
    params['user']['isin'] = isins.first
  end
  # create user
  user = User.create(params['user'])
  if user.save
    # add allowed companies set if need
    if params['user']['usertype'] == 'member' and
       not (isins.nil? or isins.empty?)
      # find companies provided by admin
      Company.all(:isin => isins).each do |c|
        # create association with user
        user.allowed_companies << c
      end
      # save, to create associations' records
      user.save
    end
    flash[:notice] = "User was created."
    # send mail
    if send_mail
      login_url = "http://#{request.host}" +
                  ([80, 443].include?(request.port) ? "" : ":#{request.port}") +
                  "/login"
      mail_body = erb(:'/emails/user_welcome',
                      :layout => :'emails/layout',
                      :locals => {
                        :user      => user,
                        :login_url => login_url
                       })
      
      send_mail( :to        => user.email,
                 :subject   => "Your user account created",
                 :html_body => mail_body )
    end
    
    redirect '/admin/users', 303
  else
    flash[:error] = "Could not create user."
    logger.error user.errors
    erb :'admin/users/new', :layout => :'admin/layout', :locals => { :user => user }
  end
end

post '/admin/user/:user_id/update' do |user_id|
  admin_required
  user = User.get(user_id)
  if user
    params.delete('user_id')
    if user.update(params['user'])
      flash[:notice] = "User was updated."
      redirect '/admin/users', 303
    else
      flash[:error] = "Could not update user."
      logger.error user.errors.inspect
      erb :'admin/users/edit', :layout => :'admin/layout', :locals => { :user => user }
    end
  else
    flash[:error] = "Could not find user to update."
    redirect '/admin/users', 303
  end
end

get '/admin/user/:user_id/reset_pwd' do |user_id|
  admin_required

  user = User.get(user_id)
  if user.nil?
    flash[:error] = "Could not find requested user."
    redirect '/admin/users', 303
    return
  end
  
  tmp_pwd = random_password
  user.password = tmp_pwd
  user.first_login = true
  unless user.save
    flash[:error] = "Could not reset user password. Try to update user first."
    redirect "/admin/user/#{user_id}/edit", 303
    return
  end

  send_mail( :to => user.email,
             :subject => 'Company password reset',
             :html_body => erb( :'pwd_change/admin_reset_pwd_email',
                                :layout => false,
                                :locals => {
                                  :tmp_pwd => tmp_pwd,
                                  :user => user
                                } ) )

  flash[:notice] = "User password was reset successfully. E-mail sent."

  redirect '/admin/users', 303
end
