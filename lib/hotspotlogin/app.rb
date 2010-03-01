require 'rubygems'
require 'sinatra/base'

module HotSpotLogin 
  class App < Sinatra::Base

    get '/' do
      "hello!"
    end

  end
end

