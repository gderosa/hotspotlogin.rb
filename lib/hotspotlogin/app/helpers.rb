require 'sinatra/base'
require 'hotspotlogin/constants'

module HotSpotLogin
  class App < Sinatra::Base
    helpers do
      def status_window?(result)
        # LOGOFF excluded since I get "undefined" as accounting data.
        # There should be a way to 'save' data and display a 'summary'
        # just after logoff...
        [
          HotSpotLogin::Result::SUCCESS,
          #HotSpotLogin::Result::LOGOFF,
          HotSpotLogin::Result::PopUp::SUCCESS,
          #HotSpotLogin::Result::PopUp::LOGOFF
        ].include? result
      end
    end
  end
end
