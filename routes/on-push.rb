require 'hipchat'

post '/on-push' do
  push = JSON::parse params[:payload]
  msg = ''
  push["commits"].each do |commit|
    msg << "#{commit["author"]["name"]} pushed <a href=\"#{commit["url"]}\"> #{commit["message"]}</a><br>"
  end
  msg << "restarting server..."
  hipchat_send( msg )
  ok = system('git pull && sudo bundle install && thin -C /etc/thin/Valuation-Metrics.yml restart')
end
