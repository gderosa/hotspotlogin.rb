require 'rubygems'
require 'facets/string'
require 'sinatra/base'
require 'sinatra/r18n'
require 'erb'

require 'hotspotlogin/constants'
require 'hotspotlogin/config'
require 'hotspotlogin/extensions/string'

module HotSpotLogin 
  class App < Sinatra::Base

    set :root, File.dirname(__FILE__) + '/../..'
    enable :show_exceptions

    set :bind,    HotSpotLogin.config['listen-address']
    set :port,    HotSpotLogin.config['port']
    set :logging, HotSpotLogin.config['log-http']

    register Sinatra::R18n

    #set :run,     false

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
      redirect "/hotspotlogin?#{request.query_string}"
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

    get '/hotspotlogin/js/UserStatus.js' do
      content_type 'text/javascript'
      erb :"js/UserStatus.js", :layout => false # localized strings...
    end
    
    get '/hotspotlogin/' do # the trailing '/' causes issues apparently
      redirect "/hotspotlogin?#{request.query_string}"
    end
    
    get '/hotspotlogin' do # the trailing '/' causes issues apparently 
      if HotSpotLogin.config['uamsecret'] and
          HotSpotLogin.config['uamsecret'].length > 0
        uamsecret = HotSpotLogin.config['uamsecret']
      else
        uamsecret = nil
      end
      userpassword = HotSpotLogin.config['userpassword']

      # attempt to login
      if params['login'] # or (
        # params['res'] == 'notyet' and request.cookies['UserName'] =~ /\S/
      # ) 

        if params['login']  # submit form button
          #if params['UserName'] =~ /\S/ # save empty credentials as a way to reset cookie content
          if params['remember_me'] == 'on'
            %w{UserName Password}.each do |k|
              if params[k]
                response.set_cookie(k, 
                                    :value    => params[k],
                                    :path     => '/',
                                    :expires  => Time.now+180*24*60*60
                )
              end
            end
          else
            %w{UserName Password}.each do |k|
              response.delete_cookie k
            end
          end
        #else                # from cookies
        # %w{chal uamip uamport UserName Password}.each do |k|
        #   params[k] = request.cookies[k] if request.cookies[k]
        # end
        end

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
        titel = headline = t.login.result.logging_into.uppercase + '...'
                                                        # 'Logging in to HotSpot'

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
        titel = headline = t.login.result.success.uppercase   
                                                  # 'Logged in to HotSpot'
        bodytext = 'Welcome' # used?
      elsif params['res'] == 'failed' 
        result = Result::FAILED
        titel = headline = t.login.result.failed.uppercase    
                                                  # 'HotSpot Login Failed'
      elsif params['res'] == 'logoff'
        result = Result::LOGOFF
        titel = headline = t.login.result.logoff.uppercase    
                                                  # 'Logged out from HotSpot'
      elsif params['res'] == 'already' 
        result = Result::ALREADY 
        titel = headline = t.login.result.already.uppercase   
                                                  # 'Already logged in to HotSpot'
      elsif params['res'] == 'notyet'
        result = Result::NOTYET
        titel = headline = t.login.result.notyet.uppercase    
                                                  # 'Logged out from HotSpot'
      elsif params['res'] == 'popup1'
        result = Result::PopUp::LOGGING_IN
        titel = t.login.result.logging_into.uppercase + '...'
                                                  # 'Logging into HotSpot'
        headline = t.login.result.success.uppercase
                                                  # 'Logged in to HotSpot'
      elsif params['res'] == 'popup2'
        result = Result::PopUp::LOGGED_IN
        titel = headline = t.login.result.success.uppercase
                                                  # 'Logged in to HotSpot'
      elsif params['res'] == 'popup3'
        result = Result::PopUp::LOGGED_OUT
        titel = headline = t.login.result.logoff.uppercase
                                                  # 'Logged out from HotSpot'

      elsif params['res'] == '' or !params['res'] # Not a form request nor a redirect..
        result = Result::NONE
        titel = t.login.result.none.uppercase    # 'What do you want here?'
        headline = t.login.result.failed.uppercase
                                                  # 'HotSpot Login Failed'
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

          # necessary/explicit to access HTTPS JSON(P)
          :chilli_json_host => HotSpotLogin.config['chilli-json-host']  || params['uamip'],
          :chilli_json_port => HotSpotLogin.config['chilli-json-port']  || params['uamport'],
          :chilli_json_ssl  => HotSpotLogin.config['chilli-json-ssl']   || false,

          :userurl          => params['userurl'],
          #:redirurl        => params['redirurl'],
          :redirurl         => params['userurl'],
          :timeleft         => params['timeleft'], # legacy... 
          :interval         => HotSpotLogin.config['interval'],
          :signup_url       => HotSpotLogin.config['signup-url'],
          :my_url           => HotSpotLogin.config['my-url'],
          :custom_headline  => 
              HotSpotLogin.config['custom-headline'], # like "MyOrg Name"
          :custom_text      => HotSpotLogin.config['custom-text'],
          :custom_footer    => HotSpotLogin.config['custom-footer'],
          :logoext          => logoext,
          :logo_link        => HotSpotLogin.config['logo-link'],
          :result           => result,
          :reply            => params['reply'] # Reply-Message
        }
      )

    end

  end
end

