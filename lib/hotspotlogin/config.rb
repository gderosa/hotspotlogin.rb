module HotSpotLogin
  # Identifiers are strongly modeled on ChilliSpot's hotspotlogin.cgi
  # and hotspologin.php 
  # (found in: http://www.chillispot.info/chilliforum/viewtopic.php?pid=80#p80)

  UAMSECRET       = 'uamsecret'
  USERPASSWORD    = true

  # TODO: do not hardcode, use cmdline options or config files 

  @@config        = {
    :uamsecret      => UAMSECRET,
    :userpassword   => USERPASSWORD
  } 

  def self.config; @@config; end

end
