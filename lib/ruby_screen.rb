$:.unshift File.dirname(__FILE__)
require 'preferences_loader'
require 'configuration'
require 'configuration_generator'

module RubyScreen
  def self.process(arguments)
    preferences_hash = PreferencesLoader.load
    ConfigurationGenerator.new(arguments, preferences_hash).generate
  end
end
