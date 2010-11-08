#!/usr/bin/env ruby

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

config = HotSpotLogin.config!

if config['daemon']
  pid = fork do
    Process.setsid
    if config['log'] 
      STDOUT.reopen(config['log'], 'a')
      STDERR.reopen(config['log'], 'a') 
      Signal.trap('USR1') do
        STDOUT.flush
        STDERR.flush
      end
    end
    HotSpotLogin::App.run!
    FileUtils.rm config['pid'] if config['pid'] and File.exists? config['pid']
  end
  if config['pid'] =~ /\S/ 
    File.open config['pid'], 'w' do |f|
      f.write pid 
    end
  end
  Process.detach pid
else # run in foreground
  HotSpotLogin::App.run!
end
