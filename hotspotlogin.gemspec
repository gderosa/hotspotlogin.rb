Gem::Specification.new do |s|
  s.name = %q{hotspotlogin}
  s.version = "0.1.0"
  s.date = %q{2010-03-04}
  s.authors = ["Guido De Rosa"]
  s.email = %q{guidoderosa@gmail.com}
  s.summary = %q{Ruby/Sinatra implementation of the login page used with ChilliSpot and friends.}
  s.homepage = %q{http://github.com/gderosa/hotspotlogin.rb}
  s.description = %q{Traditionally, a PHP or Perl/CGI web page has been used to login unauthenticated users to a Network Acces Controller like ChilliSpot; this hotspotlogin implementation is based on Ruby and Sinatra (the classy web framework).} 
  s.files = ["doc/examples/hotspotlogin.conf.yaml", "README", "views/layout.erb", "views/hotspotlogin.erb", "views/404.erb", "views/_login_form.erb", "bin/hotspotlogin_ctl.rb", "bin/hotspotlogin.rb", "lib/hotspotlogin.rb", "lib/hotspotlogin/config.rb", "lib/hotspotlogin/app.rb", "lib/hotspotlogin/extensions/string.rb"]
  s.executables = ['hotspotlogin.rb', 'hotspotlogin_ctl.rb']
  s.add_dependency 'sinatra'
  s.add_dependency 'daemons'
end
