require "#{File.dirname(__FILE__)}/lib/hotspotlogin/constants" 

Gem::Specification.new do |s|
  s.name = %q{hotspotlogin}
  s.version = HotSpotLogin::VERSION
  s.authors = ["Guido De Rosa"]
  s.email = %q{guido.derosa@vemarsas.it}
  s.summary = %q{Ruby/Sinatra implementation of the login page used with ChilliSpot and friends.}
  s.homepage = %q{http://github.com/gderosa/hotspotlogin.rb}
  s.description = %q{Traditionally, a PHP or Perl/CGI web page has been used to login unauthenticated users to a Network Access Controller like ChilliSpot; this hotspotlogin implementation is based on Ruby and Sinatra (the classy web framework).} 
  s.files = [
    "README.rdoc", 
    "bin/hotspotlogin", 
    "examples/hotspotlogin.conf.yaml", 
    "examples/etc/lighttpd/lighttpd.conf",
    "lib/hotspotlogin.rb", 
    "lib/hotspotlogin/app.rb", 
    "lib/hotspotlogin/app/helpers.rb",
    "lib/hotspotlogin/constants.rb", 
    "lib/hotspotlogin/config.rb", 
    "lib/hotspotlogin/extensions/string.rb",
    "public/hotspotlogin/css/default.css",
    "public/hotspotlogin/js/ChilliLibrary.js",
    "public/hotspotlogin/js/UserStatus.js",
    "views/layout.erb", 
    "views/hotspotlogin.erb", 
    "views/404.erb", 
    "views/_login_form.erb", 
  ]
  s.extra_rdoc_files = ["README.rdoc"]
  s.rdoc_options = ["--main", "README.rdoc"]
  s.executables = ['hotspotlogin'] 
  s.add_dependency 'sinatra'
end
