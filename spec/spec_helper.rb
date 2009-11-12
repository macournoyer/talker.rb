require "rubygems"
require "yaml"
require 'spec'
$:.unshift File.dirname(__FILE__) + "/../lib"
require "talker"

# Installing em-spec from http://github.com/macournoyer/em-spec
require 'em/spec'
require 'em/spec/rspec'
EM.spec_backend = EM::Spec::Rspec

TALKER_CONFIG = YAML.load_file(File.dirname(__FILE__) + "/talker.yml")

module Helpers
  def connect(&callback)
    Talker.connect :room => TALKER_CONFIG["room"].to_i, :token => TALKER_CONFIG["token"], &callback
  end
end

Spec::Runner.configure do |config|
  config.include Helpers
end