require 'talker/client'

module Talker
  def self.connect(options={})
    Client.connect(options)
  end
end
