#!/usr/bin/env ruby

# Don'use this hack, since it breaks /proc/<pid>/cmdline
# $0 = 'hotspotlogin.rb'

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

# The $0 hack also would break the following code :-/

# RubyGems sucks 'cause it includes bin/ directories into the $LOAD_PATH
#
# So, this file may be actually used to just 'require' the 
# hotspotlogin library (in this case $0 != __FILE__) 

if $0 == __FILE__ # actually start hotspotlogin service
  config = HotSpotLogin.config!

  if config['daemon']
    pid = fork do
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
  else # run in foreground
    HotSpotLogin::App.run!
  end
end
