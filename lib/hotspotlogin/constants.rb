module HotSpotLogin

  VERSION = '0.1.2'

  DEFAULT_CONFIG = {
    'listen-address'    => '0.0.0.0',
    'port'              => 4990,
    'log-http'          => false,
    'userpassword'      => true # like $userpassword in hotpotlgin.(cgi|php)
  } 

  # corresponding GET parameters are res=success, res=failed etc.
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
  end
   
end
