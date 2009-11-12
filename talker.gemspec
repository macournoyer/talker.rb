Gem::Specification.new do |s|
  s.name            = %q{talker}
  s.version         = "0.0.1"
 
  s.authors         = ["Marc-Andre Cournoyer"]
  s.email           = "macournoyer@talkerapp.com"
  s.files           = Dir["*/**"]
  s.homepage        = "http://github.com/macournoyer/talker.rb"
  s.require_paths   = ["lib"]
  s.bindir          = "bin"
  s.executables     = "talker"
  s.summary         = "A real-time Talker Ruby client."
  s.test_files      = Dir["spec/**"]
  
  s.add_dependency  "eventmachine"
  s.add_dependency  "yajl-ruby"
end