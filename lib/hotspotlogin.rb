$LOAD_PATH.unshift(File.dirname(__FILE__)) unless
    $LOAD_PATH.include?(File.dirname(__FILE__)) || 
    $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

require 'hotspotlogin/app'

