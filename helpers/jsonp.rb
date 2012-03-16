require 'json'

module Sinatra
  module JsonP

    def jsonp(params, data)
      callback = params['callback']
      json = JSON.pretty_generate data

      if callback
        content_type :js
        return "#{callback}(#{json})"
      else
        return json
      end
    end

  end

  helpers JsonP
end
