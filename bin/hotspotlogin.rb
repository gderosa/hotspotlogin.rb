#!/usr/bin/env ruby

$0 = 'hotspotlogin.rb'

require 'rubygems'
require 'sinatra/base'

if File.symlink? __FILE__
  file = File.readlink __FILE__
else
  file = __FILE__
end

require File.expand_path(
  File.dirname(file) + "/../lib/hotspotlogin"
)

HotSpotLogin.config! 

HotSpotLogin::App.run!

