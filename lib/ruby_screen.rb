$:.unshift File.dirname(__FILE__)
require 'preferences_loader'
require 'configuration/description'
require 'configuration/generator'

module RubyScreen
  def self.process(arguments)
    preferences_hash = PreferencesLoader.load
    Configuration::Generator.new(arguments, preferences_hash).generate
  end
end
