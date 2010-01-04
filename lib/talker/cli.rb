module Talker
  class CLI
    def self.load_token
      token_path = File.join(ENV['HOME'], '.talker')
      
      unless File.file?(token_path)
        abort <<-EOS
      Place your Talker Token in #{token_path}. You can find your
      token in https://myaccount.talkerapp.com/settings
      EOS
      end
      
      File.read(token_path).strip
    end
  end
end