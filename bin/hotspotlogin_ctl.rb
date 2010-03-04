#!/usr/bin/env ruby

require 'rubygems'
require 'daemons'

Daemons.run(
  "#{File.dirname __FILE__}/hotspotlogin.rb",
  {
    :dir_mode => :system
  }
)


