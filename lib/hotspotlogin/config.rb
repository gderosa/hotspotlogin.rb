require 'optparse'
require 'yaml'

require 'hotspotlogin/constants'

module HotSpotLogin

  @@config = DEFAULT_CONFIG unless class_variable_defined? :@@config

  def self.config; @@config; end

  def self.config=(h) 
    @@config = h
    config_sinatra!
  end

  # Parses command line and configuration file
  def self.config!
    OptionParser.new do |opts|
      opts.banner = "Usage: #{$0} [options]"

      # Configuration file, if specified.

      opts.on('--conf FILE', 'configuration file') do |filename|
        @@config['conf'] = filename
        @@config.merge! YAML.load(File.read filename) 
      end

      # Command line switches override configuration file.
      
      opts.on('--interval SECONDS', 'autorefresh accounting/session data every SECONDS seconds') do |seconds|
        @@config['interval'] = seconds.to_i
      end

      opts.on('--custom-headline TEXT', 'display <h1>TEXT</h1> on top of the login page, tipically your Organization name') do |text|
        @@config['custom-headline'] == text
      end

      opts.on('--custom-text FILE', 'display HTML fragment FILE before the user stats table/login form') do |file|
        @@config['custom-text'] == file
      end

      opts.on('--custom-footer FILE', 'display HTML fragment FILE after the user stats table/login form') do |file|
        @@config['custom-footer'] == file
      end

      opts.on('--logo FILE', 'logo (of your Organization etc.)') do |file|
        @@config['logo'] = file
      end

      opts.on('--logo-link URL', 'add an hyperlink to the logo') do |url|
        @@config['logo-link'] = url
      end

      opts.on('--my-url URL', 'display a "My Account" link, -USER- will be dinamically replaced by the actual username, e.g. https://accounts.myorg.com/?id=-USER-') do |url|
        @@config['my-url'] = url
      end

      opts.on('--signup-url URL', 'display an external link where end-user may create a new account') do |url|
        @@config['signup-url'] = url
      end

      opts.on('--favicon FILE', 'well, favicon ;)') do |file|
        @@config['favicon'] = file
      end
     
      opts.on('--[no-]daemon', 'become a daemon') do |daemonize|
        @@config['daemon'] = daemonize
      end

      opts.on('--log FILE', 'log file (overwrite existing)') do |filename|
        @@config['log'] = filename
      end

      opts.on('--pid FILE', 'pid file') do |filename|
        @@config['pid'] = filename
      end

      opts.on('--uamsecret PASS', 'as in chilli.conf(5)') do |uamsecret|
        @@config['uamsecret'] = uamsecret
      end

      opts.on('--[no-]userpassword', 'like setting $userpassword=1 in hotspotlogin.cgi (use PAP instead of CHAP)') do |userpassword|
        @@config['userpassword'] = userpassword
      end

      opts.on('--port PORT', 'TCP port to listen on') do |port|
        @@config['port'] = port.to_i
      end

      opts.on('--listen-address ADDR', 'IP address or hostname to listen on') do |addr|
        @@config['listen-address'] = addr
      end

      opts.on('--[no-]log-http', 'output an Apache-like log') do |log|
        @@config['log-http'] = log
      end

    end.parse!

    self.config_sinatra!

    return @@config
  end

  private  

  def self.config_sinatra!
    App.set :host,    @@config['listen-address']
    App.set :port,    @@config['port']
    App.set :logging, @@config['log-http']
  end

end
