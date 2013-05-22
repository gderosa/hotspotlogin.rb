require 'optparse'
require 'yaml'

require 'hotspotlogin/constants'

module HotSpotLogin

  def self.config
    begin
      return @@config
    rescue NameError
      config!
      retry
    end
  end

  def self.config=(h) 
    @@config = h
  end

  # Parses command line and configuration file
  def self.config!
    @@config = DEFAULT_CONFIG
    @@cmdline_config = {}

    OptionParser.new do |opts|
      opts.banner = "Usage: #{$0} [options]"

      # Configuration file, if specified.

      opts.on('--conf FILE', 'configuration file') do |filename|
        @@cmdline_config['conf'] = filename
      end

      # Command line switches override configuration file.
      
      opts.on('--interval SECONDS', 'autorefresh accounting/session data every SECONDS seconds') do |seconds|
        @@cmdline_config['interval'] = seconds.to_i
      end

      # Options which might be useful if JSON(P) status info are fetched from Chilli via HTTPS
      opts.on('--chilli-json-host HOST', "fetch status info from HOST (name or IP); it defaults to ``uamip'' GET parameter provided by (Coova)Chilli, but might need to be explicited if a name is necessary rather than an IP -- e.g. when getting such info via HTTPS and web browsers might refuse to load them otherwise") do |host|
        @@cmdline_config['chilli-json-host'] = host
      end
      opts.on('--chilli-json-port PORT', "fetch status info from PORT (see also --chilli-json-host); it defaults to ``uamport'' GET parameter provided by (Coova)Chilli, but needs to be explicited if SSL is used -- Coova Chilli uses a different port, which tipically is uamuiport, if uamuissl is enabled (as in chilli.conf(5))") do |port|
        @@cmdline_config['chilli-json-host'] = port
      end
      opts.on('--[no-]chilli-json-ssl', "fetch status info using SSL") do |use_ssl|
        @@cmdline_config['chilli-json-ssl'] = use_ssl
      end

      opts.on('--[no-]ssl', "listen on HTTPS (without requiring a fronting webserver)") do |use_ssl|
        @@cmdline_config['ssl'] = use_ssl
      end

     opts.on('--ssl-cert FILE', "use FILE as SSL certificate to serve HTTPS") do |file|
        @@cmdline_config['ssl-cert'] = file
      end

      opts.on('--ssl-key FILE', "use FILE as SSL private key to serve HTTPS") do |file|
        @@cmdline_config['ssl-key'] = file
      end

      opts.on('--custom-headline TEXT', 'display <h1>TEXT</h1> on top of the login page, tipically your Organization name') do |text|
        @@cmdline_config['custom-headline'] == text
      end

      opts.on('--custom-text FILE', 'display HTML fragment FILE before the user stats table/login form') do |file|
        @@cmdline_config['custom-text'] == file
      end

      opts.on('--custom-footer FILE', 'display HTML fragment FILE after the user stats table/login form') do |file|
        @@cmdline_config['custom-footer'] == file
      end

      opts.on('--logo FILE', 'logo (of your Organization etc.)') do |file|
        @@cmdline_config['logo'] = file
      end

      opts.on('--logo-link URL', 'add an hyperlink to the logo') do |url|
        @@cmdline_config['logo-link'] = url
      end

      opts.on('--my-url URL', 'display a "My Account" link, -USER- will be dinamically replaced by the actual username, e.g. https://accounts.myorg.com/?id=-USER-') do |url|
        @@cmdline_config['my-url'] = url
      end

      opts.on('--signup-url URL', 'display an external link where end-user may create a new account') do |url|
        @@cmdline_config['signup-url'] = url
      end

      opts.on('--favicon FILE', 'well, favicon ;)') do |file|
        @@cmdline_config['favicon'] = file
      end
     
      opts.on('--[no-]daemon', 'become a daemon') do |daemonize|
        @@cmdline_config['daemon'] = daemonize
      end

      opts.on('--log FILE', 'log file (overwrite existing)') do |filename|
        @@cmdline_config['log'] = filename
      end

      opts.on('--pid FILE', 'pid file') do |filename|
        @@cmdline_config['pid'] = filename
      end

      opts.on('--uamsecret PASS', 'as in chilli.conf(5)') do |uamsecret|
        @@cmdline_config['uamsecret'] = uamsecret
      end

      opts.on('--[no-]userpassword', 'like setting $userpassword=1 in hotspotlogin.cgi (use PAP instead of CHAP)') do |userpassword|
        @@cmdline_config['userpassword'] = userpassword
      end

      opts.on('--port PORT', 'TCP port to listen on') do |port|
        @@cmdline_config['port'] = port.to_i
      end

      opts.on('--listen-address ADDR', 'IP address or hostname to listen on') do |addr|
        @@cmdline_config['listen-address'] = addr
      end

      opts.on('--[no-]log-http', 'output an Apache-like log') do |log|
        @@cmdline_config['log-http'] = log
      end

    end.parse!

    if @@cmdline_config['ssl-cert'] =~ /\S/ and not @@cmdline_config.keys.include? 'ssl'
      @@cmdline_config['ssl'] = true
    end
    conffilepath = @@cmdline_config['conf']
    if conffilepath and File.readable? conffilepath
      @@config.update YAML.load(File.read conffilepath)
    end
    @@config.update @@cmdline_config

    return @@config
  end

end
