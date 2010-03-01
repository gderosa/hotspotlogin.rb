require 'rubygems'
require 'sinatra/base'
require 'haml'
require 'pp'

require 'hotspotlogin/config'

module HotSpotLogin 
  class App < Sinatra::Base

    set :root, File.dirname(__FILE__) + '/../..'

    not_found do
      haml :"404" # Sinatra doesn't know this ditty ;-)
    end

    get '/' do
      haml(
        :hotspotlogin,
        :locals => {
          :config => HotSpotLogin.config
        }
      )
    end

  end
end

