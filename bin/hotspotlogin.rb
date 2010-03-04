#!/usr/bin/env ruby

$0 = 'hotspotlogin.rb'

require 'rubygems'
require 'sinatra/base'

require File.expand_path(File.dirname(__FILE__) + "/../lib/hotspotlogin")

HotSpotLogin.config! 

HotSpotLogin::App.run!

