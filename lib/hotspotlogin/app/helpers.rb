require 'sinatra/base'
require 'hotspotlogin/constants'

module HotSpotLogin
  class App < Sinatra::Base
    helpers do
      def logged_in?(result)
        [
          HotSpotLogin::Result::ALREADY,
          HotSpotLogin::Result::SUCCESS,
          HotSpotLogin::Result::PopUp::SUCCESS,
        ].include? result
      end
      alias status_window? logged_in?
    end
  end
end
