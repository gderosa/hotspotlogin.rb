require 'rubygems'
require 'sinatra/base'
require 'haml'

module HotSpotLogin 
  class App < Sinatra::Base

    set :root, File.dirname(__FILE__) + '/../..'

    not_found do
      haml :"404"
    end

    get '/' do
      haml :hotspotlogin
    end

  end
end

