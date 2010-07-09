require 'talker/client'

module Talker
  def self.connect(options={}, &blk)
    Client.connect(options, &blk)
  end
end
