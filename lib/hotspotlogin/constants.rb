module HotSpotLogin

  VERSION = '1.3.1'

  DEFAULT_CONFIG = {
    'listen-address'    => '0.0.0.0',
    'port'              => 4990,
    'log-http'          => false,
    'userpassword'      => true, # like $userpassword in hotpotlgin.(cgi|php)
    'interval'          => 300
  } 

  ROOTDIR = File.join(File.dirname(File.expand_path __FILE__), '../..')

  # Corresponding GET parameters are res=success, res=failed, res=popup1, etc.
  module Result
    SUCCESS =  1
    FAILED  =  2
    LOGOFF  =  3  # logged out
    ALREADY =  4
    NOTYET  =  5
    POPUP1  = 11
    POPUP2  = 12
    POPUP3  = 13
    NONE    =  0  # It was not a form request
    
    # More meaningful constants for popup windows.
    module PopUp
      LOGGING_IN  = POPUP1
      LOGGED_IN   = POPUP2
      LOGGED_OUT  = POPUP3

      # convenient aliases
      LOGGING     = LOGGING_IN 
      LOGGED      = LOGGED_IN
      SUCCESS     = LOGGED_IN
      LOGOFF      = LOGGED_OUT
      LOGOUT      = LOGOFF
    end
  end
   
end
