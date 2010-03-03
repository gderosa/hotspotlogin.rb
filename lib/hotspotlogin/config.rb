require 'optparse'
require 'yaml'

module HotSpotLogin

  # defaults

  # UAMSECRET       = 'uamsecret'
  # USERPASSWORD    = true
  PORT            = 4990

  @@config        = {
    # 'uamsecret'     => UAMSECRET,
    # 'userpassword'  => USERPASSWORD,
    'port'          => PORT
  } 

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

      opts.on('--userpassword', 'like setting $userpassword=1 in hotspotlogin.cgi') do |v|
        @@config['userpassword'] = true
      end

      opts.on('--port PORT', 'TCP port to listen on') do |v|
        @@config['port'] = v.to_i
      end
    end.parse!
  end
    
end
