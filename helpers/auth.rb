module Sinatra
  module AuthHelpers
    def login_required
      puts "login_required"
      if session[:user] and current_user
        if current_user.first_login
          redirect '/firstlogin', 303
        end
        
        return true
      else
        if request.env['REQUEST_PATH'] =~ /(\.json|\.xml)$/ and
           request.env['HTTP_USER_AGENT'] !~ /Mozilla/

          @auth ||= Rack::Auth::Basic::Request.new(request.env)

          if @auth.provided? and @auth.basic? and @auth.credentials and
             User.authenticate(@auth.credentials.first, @auth.credentials.last)

            user           = User.first(:email => @auth.credentials.first)
            session[:user] = user.id
            if user.first_login
              redirect '/firstlogin', 303
            end
              
            return true
          else
            @response.status = 401
            halt rescue throw :halt
          end
        end

        session[:return_to] = request.fullpath
        redirect '/login', 303
        return false
      end
    end

    def admin_required
      return true if login_required and current_user.admin?
      redirect GlobalSettings.default_user_home, 303
    end

    def current_user
      User.get(session[:user])
    end

    def redirect_to_stored
      if return_to = session[:return_to]
        session[:return_to] = nil
        redirect return_to, 303
      else
        redirect GlobalSettings.default_user_home, 303
      end
    end

    def clean(str); str.gsub(/^\s{#{str[/\s+/].length}}/, ''); end
  end

  helpers AuthHelpers
end