$:.unshift File.dirname(__FILE__)
require 'ruby_screen/preferences_loader'
require 'ruby_screen/executer'
require 'ruby_screen/configuration/description'
require 'ruby_screen/configuration/parser'
require 'ruby_screen/configuration/generator'

module RubyScreen
  def self.process(arguments)
    preferences_hash = PreferencesLoader.load
    description = Configuration::Parser.parse(arguments, preferences_hash)
    Executer.new(description)
  end
end
