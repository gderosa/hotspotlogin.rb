require "#{File.dirname(__FILE__)}/lib/hotspotlogin/constants" 

Gem::Specification.new do |s|
  s.name = %q{hotspotlogin}
  s.version = HotSpotLogin::VERSION
  s.authors = ["Guido De Rosa"]
  s.email = %q{guido.derosa@vemarsas.it}
  s.summary = %q{Login page/Captive portal based on Sinatra and the CoovaChilli JSON API}
  s.homepage = %q{http://dev.vemarsas.it/projects/hospotlogin/wiki}
  s.description = %q{Traditionally, a PHP or Perl/CGI web page has been used to login unauthenticated users to a Network Access Controller like ChilliSpot; this hotspotlogin implementation is based on Sinatra instead, and relies heavily on the CoovaChilli JSON interface.} 
  s.files = [
    "Changelog",
    "README.rdoc", 
    "bin/hotspotlogin", 
    "examples/hotspotlogin.conf.yaml", 
    "examples/etc/lighttpd/lighttpd.conf",
    "i18n/en.yml",
    "i18n/it.yml",
    "lib/hotspotlogin.rb", 
    "lib/hotspotlogin/app.rb", 
    "lib/hotspotlogin/app/helpers.rb",
    "lib/hotspotlogin/constants.rb", 
    "lib/hotspotlogin/config.rb", 
    "lib/hotspotlogin/extensions/string.rb",
    "public/hotspotlogin/css/default.css",
    "public/hotspotlogin/js/ChilliLibrary.js",
    "views/js/UserStatus.js.erb",
    "views/layout.erb", 
    "views/hotspotlogin.erb", 
    "views/404.erb", 
    "views/_login_form.erb", 
  ]
  s.extra_rdoc_files = ["README.rdoc"]
  s.rdoc_options = ["--main", "README.rdoc"]
  s.executables = ['hotspotlogin'] 
  
  s.add_dependency 'facets'
  s.add_dependency 'sinatra', '>= 1.4.1'
    # http://stackoverflow.com/questions/11405161/enable-ssl-in-sinatra-with-thin/15511536#15511536
    # and some config-related issues...
  s.add_dependency 'thin'
  s.add_dependency 'eventmachine' 
    # NOTE NOTE NOTE: eventmachine (which is ultimately a Sinatra dependency) 
    # needs to be compiled with OpenSSL support to allow SSL options. 
    # Don't know how to require this in gemspec...
  s.add_dependency 'rack' 
    # we use Rack::Utils explicitly
  s.add_dependency 'sinatra-r18n'
end
