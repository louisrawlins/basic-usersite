require 'sinatra'
require 'sinatra/content_for'
require 'sinatra/config_file'
require 'sinatra_more/markup_plugin'

require 'rack-flash'
require 'rack/contrib/jsonp'

require 'crack'
require 'yaml'

require 'redis'

$LOAD_PATH << './lib'

CONFIG = YAML::load_file 'config.yaml'

class BasicUserSite < Sinatra::Application
  set :public_folder, ::File.dirname(__FILE__) + '/public'

  use Rack::JSONP
  use Rack::Flash
  register SinatraMore::MarkupPlugin
  enable :logging
  enable :sessions

  set :environments, %w{local development test production}
  config_file 'config.yaml'

  set :redis, nil

  if settings.remote_syslog
    require 'uri'
    require 'remote_syslog_logger'

    uri = URI.parse settings.remote_syslog
    logger = RemoteSyslogLogger::UdpSender.new( uri.host, uri.port,
                                                :program => uri.path[1..-1] )
    use Rack::CommonLogger, logger
  end

  configure :production do
    set :erb, { :ugly => true }
    set :clean_trace, true
    set :static_cache_control, [:public, :max_age => 60 * 60]
  end

  configure :development do
    set :erb, { :ugly => false }
    set :static_cache_control, [:public, :max_age => 5 * 60]
  end

  configure :local do
    set :reload_templates, true
    set :erb, { :ugly => false }
  end

  configure :test do
    set :views, root + '/test/views'
    set :redis, Redis.connect( db:13 )
  end

  helpers do
    include Rack::Utils
    alias_method :h, :escape_html
  end
end

require_relative 'models/init'
require_relative 'helpers/init'
require_relative 'routes/init'
