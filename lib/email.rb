require 'pony'

def send_mail(*args)
  Pony.mail( args.last.merge( :from => 'do-not-reply@vminc.co',
                              :via => :smtp,
                              :via_options => {
                                :address              => 'smtp.gmail.com',
                                :port                 => '587',
                                :enable_starttls_auto => true,
                                :user_name            => 'basic.user.site',
                                :password             => 'weerooF0',
                                :authentication       => :plain,
                                :domain               => "example.com"
                              } ) )
end
