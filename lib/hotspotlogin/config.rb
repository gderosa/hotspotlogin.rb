require 'optparse'
require 'yaml'

module HotSpotLogin

  DEFAULT_CONFIG = {
    'listen-address'    => '0.0.0.0',
    'port'              => 4990,
    'log-http'          => false,
    'userpassword'      => false # like $userpassword in hotpotlgin.(cgi|php)
  } 

  @@config = DEFAULT_CONFIG unless class_variable_defined? :@@config

  def self.config; @@config; end

  def self.config=(h); @@config = h; end

  # Parses command line and configuration file
  def self.config!
    OptionParser.new do |opts|
      opts.banner = "Usage: #{$0} [options]"

      opts.on('--conf FILE', 'configuration file') do |filename|
        @@config['conf'] = filename
        @@config.merge! YAML.load(File.read filename) 
      end

      opts.on('--uamsecret PASS', 'as in chilli.conf(5)') do |uamsecret|
        @@config['uamsecret'] = uamsecret
      end

      opts.on('--userpassword', 'like setting $userpassword=1 in hotspotlogin.cgi') do
        @@config['userpassword'] = true
      end

      opts.on('--port PORT', 'TCP port to listen on') do |port|
        @@config['port'] = port.to_i
      end

      opts.on('--listen-address ADDR', 'IP address or hostname to listen on') do |addr|
        @@config['listen-address'] = addr
      end

      opts.on('--log-http', 'output an Apache-like log') do 
        @@config['log-http'] = true
      end

    end.parse!

    # Now, set the Sinatra App
    App.set :host,    @@config['listen-address']
    App.set :port,    @@config['port']
    App.set :logging, @@config['log-http']
    
  end
    
end
