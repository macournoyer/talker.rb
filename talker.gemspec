Gem::Specification.new do |s|
  s.name            = "talker"
  s.version         = "0.0.4"
 
  s.authors         = ["Marc-Andre Cournoyer"]
  s.email           = "macournoyer@talkerapp.com"
  s.files           = Dir["**/*"]
  s.homepage        = "http://github.com/macournoyer/talker.rb"
  s.require_paths   = ["lib"]
  s.bindir          = "bin"
  s.executables     = Dir["bin/*"].map { |f| File.basename(f) }
  s.summary         = "A real-time Talker Ruby client."
  s.test_files      = Dir["spec/**"]
  
  s.add_dependency  "eventmachine"
  s.add_dependency  "yajl-ruby"
end