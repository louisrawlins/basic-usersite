module Sinatra
  module HipChatHelper

    def hipchat_send(msg)
      hipchat = HipChat::Client.new( 'a2af5e943466aadce89d41f5611466' )
      hipchat["Basic User Site"].send( 'site-deploy', msg, :notify => false )
    end

  end

  helpers HipChatHelper
end
