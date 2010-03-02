require 'rubygems'
require 'sinatra/base'
require 'erb'
require 'pp'

require 'hotspotlogin/config'

module HotSpotLogin 
  class App < Sinatra::Base

    set :root, File.dirname(__FILE__) + '/../..'
    enable :show_exceptions

    not_found do
      erb :"404" # Sinatra doesn't know this ditty ;-)
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

      if HotSpotLogin.config[:uamsecret] and
          HotSpotLogin.config[:uamsecret].length > 0
        uamsecret = HotSpotLogin.config[:uamsecret]
      else
        uamsecret = nil
      end
      userpassword = HotSpotLogin.config[:userpassword]

      # attempt to login
      if params['login'] == 'login'
        hexchal = params['chal'].chars.to_a.pack('H32')
        if uamsecret
          newchal = 
              Digest::MD5.hexdigest(hexchal + uamsecret).chars.to_a.pack('H*')
        else
          newchal = hexchal
        end
        response = Digest::MD5.hexdigest("\0" + params['Password'] + newchal)
        newpwd = params['Password'].chars.to_a.pack('a32') 
        pappassword = (newpwd ^ newchal).unpack('H32').join 

        if uamsecret and userpassword
          headers({
            'Refresh' => "0;url=http://#{params['uamip']}:#{params['uamport']}/logon?username=#{params['UserName']}&password=#{pappassword}" # NOTE: no userurl passed... why? 
          })
        else
          headers({
            'Refresh' => "0;url=http://#{params['uamip']}:#{params['uamport']}/logon?username=#{params['UserName']}&response=#{response}&userurl=#{params['userurl']}"
          })
        end

        erb(
          :hotspotlogin,
          :locals => {
            :uamip => params['uamip'],
            :uamport => params['uamport'],
            :result => '' # NOTE: WARN: in the PHP, in this case, $result is 
                          # simply not set :-(
          }
        )
      else
        erb(
          :default,
          :locals => {
            :config => HotSpotLogin.config,
            :uamip => params['uamip'],
            :uamport => params['uamport'],
            :result => ''
          }
        )
      end
    end

  end
end

