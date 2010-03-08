require 'rubygems'
require 'sinatra/base'
require 'erb'
require 'pp'

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

    # TODO: This is not classy: all that JS code should not be layout.erb;
    # to avoid failures we have to pass all this de-facto unused variables...
    # Horror  ;-/    
    not_found do # Sinatra doesn't know this ditty ;-)
      erb(
        :"404",
        :locals => {
          :titel => 'Not Found',
          :headline => headline,
          :bodytext => bodytext,
          :uamip => params['uamip'],
          :uamport => params['uamport'],
          :userurl => params['userurl'],
          :redirurl => params['redirurl'],
          :timeleft => params['timeleft'],
          :result => nil
        }
      )
    end

    # comments adapted from hotspotlogin.php :
    
    # possible Cases:
    # attempt to login                          login=login
    # 1: Login successful                       res=success
    # 2: Login failed                           res=failed
    # 3: Logged out                             res=logoff
    # 4: Tried to login while already logged in res=already
    # 5: Not logged in yet                      res=notyet
    #11: Popup                                  res=popup1
    #12: Popup                                  res=popup2
    #13: Popup                                  res=popup3
    # 0: It was not a form request              res=""

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
    

    # Matches '/', '/hotspotlogin' and '/hotspotlogin.rb'
    get %r{^/(hotspotlogin(\.rb)?/?)?$} do 

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
        if userpassword
          headers({
            'Refresh' => "0;url=http://#{params['uamip']}:#{params['uamport']}/logon?username=#{params['UserName']}&password=#{pappassword}&userurl=#{params['userurl']}" 
            # NOTE: no userurl passed... why? 
            # NOTE: if you pass it, nothing changes
          })
        else
          headers({
            'Refresh' => "0;url=http://#{params['uamip']}:#{params['uamport']}/logon?username=#{params['UserName']}&response=#{response}&userurl=#{params['userurl']}"
          })
        end
      elsif params['res'] == 'success' 
        result = 1
        titel = 'Logged in to HotSpot'
        headline = 'Logged in to HotSpot'
        bodytext = 'Welcome'
      elsif params['res'] == 'failed' 
        result = 2
        titel = 'HotSpot Login Failed'
        headline = 'HotSpot Login Failed'
      elsif params['res'] == 'logoff'
        result = 3
        titel = 'Logged out from HotSpot'
        headline = 'Logged out from HotSpot'
      elsif params['res'] == 'already' 
        result = 4
        titel = 'Already logged in to HotSpot'
        headline = 'Already logged in to HotSpot'
      elsif params['res'] == 'notyet'
        result = 5
        titel = 'Logged out from HotSpot'
        headline = 'Logged out from HotSpot'
      elsif params['res'] == 'popup1'
        result = 11
        titel = 'Logging into HotSpot'
        headline = 'Logged in to HotSpot'
      elsif params['res'] == 'popup2'
        result = 12
        titel = 'Logged in to HotSpot'
        headline = 'Logged in to HotSpot'
      elsif params['res'] == 'popup3'
        result= 13
        titel = 'Logged out from HotSpot'
        headline = 'Logged out from HotSpot'
      elsif params['res'] == '' or !params['res'] # not a form request: err!
        result = 0
        titel = 'What do you want here?'
        headline = 'HotSpot Login Failed'
      end

      erb(
        :hotspotlogin,
        :locals => {
          :titel => titel,
          :headline => headline,
          :bodytext => bodytext,
          :uamip => params['uamip'],
          :uamport => params['uamport'],
          :userurl => params['userurl'],
          #:redirurl => params['redirurl'],
          :redirurl => params['userurl'],
          :timeleft => params['timeleft'],
          :result => result
        }
      )

    end

  end
end

