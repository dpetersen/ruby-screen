$:.unshift File.dirname(__FILE__)
require 'preferences_loader'

%w[description generator].each do |f|
  require "configuration/#{f}"
end

module RubyScreen
  def self.process(arguments)
    preferences_hash = PreferencesLoader.load
    Configuration::Generator.new(arguments, preferences_hash).generate
  end
end
