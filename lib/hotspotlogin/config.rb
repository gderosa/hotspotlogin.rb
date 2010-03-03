module HotSpotLogin
  # Identifiers are strongly modeled on ChilliSpot's hotspotlogin.cgi
  # and hotspologin.php 
  # (found in: http://www.chillispot.info/chilliforum/viewtopic.php?pid=80#p80)

  UAMSECRET       = 'uamsecret'
  USERPASSWORD    = true
  PORT            = 4990

  # TODO: do not hardcode, use cmdline options or config files 

  @@config        = {
    'uamsecret'     => UAMSECRET,
    'userpassword'  => USERPASSWORD,
    'port'          => PORT
  } 

  def self.config; @@config; end

end
