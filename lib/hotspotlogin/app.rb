require 'rubygems'
require 'sinatra/base'
require 'erb'
require 'pp'

require 'hotspotlogin/constants'
require 'hotspotlogin/config'
require 'hotspotlogin/extensions/string'

module HotSpotLogin 
  class App < Sinatra::Base

    set :root, File.dirname(__FILE__) + '/../..'
    enable :show_exceptions

    set :host,    HotSpotLogin.config['listen-address']
    set :port,    HotSpotLogin.config['port']
    set :logging, HotSpotLogin.config['log-http']

    #set :run,     false

    include ERB::Util # for html_escape...

    result, titel, headline, bodytext = '', '', '', ''

    before do
      headers(
        'X-HotSpotLoginRb-Version' => HotSpotLogin::VERSION
      )
    end

    not_found do # Sinatra doesn't know this ditty ;-)
      erb(
        :"404",
        :layout => false
      )
    end

    require 'hotspotlogin/app/helpers'

    #Read query parameters which we care about
    # params['res']
    # params['challenge']
    # params['uamip']
    # params['uamport']
    # params['reply']
    # params['userurl']
    # params['timeleft']
    # params['redirurl']

    #Read form parameters which we care about
    # params['username']
    # params['password']
    # params['chal']
    # params['login']
    # params['logout']
    # params['prelogin']
    # params['res']
    # params['uamip']
    # params['uamport']
    # params['userurl']
    # params['timeleft']
    # params['redirurl']
    

    # All paths should be under /hotspotlogin, to allow easier 
    # setup of "conditional" HTTPS reverse proxies
    
    get '/' do
      redirect '/hotspotlogin'
    end

    get '/hotspotlogin/favicon.ico' do
      if HotSpotLogin.config['favicon'] 
        if File.file? HotSpotLogin.config['favicon']
          send_file HotSpotLogin.config['favicon']
        else
          not_found
        end
      else
        not_found
      end
    end

    get '/hotspotlogin/logo.:ext' do
      if HotSpotLogin.config['logo'] 
        if 
            File.file?(   HotSpotLogin.config['logo'])                      and
            File.extname( HotSpotLogin.config['logo']) == ".#{params[:ext]}"
          send_file HotSpotLogin.config['logo']
        else
          not_found
        end
      else
        not_found
      end
    end
    
    get '/hotspotlogin/?' do 
      if HotSpotLogin.config['uamsecret'] and
          HotSpotLogin.config['uamsecret'].length > 0
        uamsecret = HotSpotLogin.config['uamsecret']
      else
        uamsecret = nil
      end
      userpassword = HotSpotLogin.config['userpassword']

      # attempt to login
      if params['login'] == 'login'
        hexchal = Array[params['chal']].pack('H32')
        if uamsecret
          newchal = 
              Array[Digest::MD5.hexdigest(hexchal + uamsecret)].pack('H*')
        else
          newchal = hexchal
        end
        response = Digest::MD5.hexdigest("\0" + params['Password'] + newchal)
        newpwd = Array[params['Password']].pack('a32') 
        # bitwise XOR between (binary) Strings (operator ^) 
        # implemented in extensions/ 
        pappassword = (newpwd ^ newchal).unpack('H32').join 
        titel = 'Logging in to HotSpot'
        headline = 'Logging in to HotSpot'

        #if uamsecret and userpassword
        if userpassword # PAP
          headers({
            'Refresh' => "0;url=http://#{params['uamip']}:#{params['uamport']}/logon?username=#{params['UserName']}&password=#{pappassword}&userurl=#{params['userurl']}" 
            # NOTE: no userurl passed... why? 
            # NOTE: if you pass it, nothing changes
          })
        else # CHAP
          headers({
            'Refresh' => "0;url=http://#{params['uamip']}:#{params['uamport']}/logon?username=#{params['UserName']}&response=#{response}&userurl=#{params['userurl']}"
          })
        end
      elsif params['res'] == 'success' 
        result = Result::SUCCESS
        titel = 'Logged in to HotSpot'
        headline = 'Logged in to HotSpot'
        bodytext = 'Welcome'
      elsif params['res'] == 'failed' 
        result = Result::FAILED
        titel = 'HotSpot Login Failed'
        headline = 'HotSpot Login Failed'
      elsif params['res'] == 'logoff'
        result = Result::LOGOFF
        titel = 'Logged out from HotSpot'
        headline = 'Logged out from HotSpot'
      elsif params['res'] == 'already' 
        result = Result::ALREADY 
        titel = 'Already logged in to HotSpot'
        headline = 'Already logged in to HotSpot'
      elsif params['res'] == 'notyet'
        result = Result::NOTYET
        titel = 'Logged out from HotSpot'
        headline = 'Logged out from HotSpot'
      elsif params['res'] == 'popup1'
        result = Result::PopUp::LOGGING_IN
        titel = 'Logging into HotSpot'
        headline = 'Logged in to HotSpot'
      elsif params['res'] == 'popup2'
        result = Result::PopUp::LOGGED_IN
        titel = 'Logged in to HotSpot'
        headline = 'Logged in to HotSpot'
      elsif params['res'] == 'popup3'
        result= Result::PopUp::LOGGED_OUT
        titel = 'Logged out from HotSpot'
        headline = 'Logged out from HotSpot'
      elsif params['res'] == '' or !params['res'] # not a form request: err!
        result = Result::NONE
        titel = 'What do you want here?'
        headline = 'HotSpot Login Failed'
      end

      logoext = nil
      logoext = 
          File.extname(HotSpotLogin.config['logo']) if 
          HotSpotLogin.config['logo']

      erb(
        :hotspotlogin,
        :locals => {
          :titel            => titel,
          :headline         => headline, # like 'Logged out from HotSpot'
          :bodytext         => bodytext,
          :uamip            => params['uamip'],
          :uamport          => params['uamport'],
          :userurl          => params['userurl'],
          #:redirurl        => params['redirurl'],
          :redirurl         => params['userurl'],
          :timeleft         => params['timeleft'], # legacy... 
          :interval         => HotSpotLogin.config['interval'],
          :custom_headline  => 
              HotSpotLogin.config['custom-headline'], # like "MyOrg Name"
          :custom_text      => HotSpotLogin.config['custom-text'],
          :custom_footer    => HotSpotLogin.config['custom-footer'],
          :logoext          => logoext,
          :result           => result,
          :reply            => params['reply'] # Reply-Message
        }
      )

    end

  end
end

