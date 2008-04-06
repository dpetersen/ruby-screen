$:.unshift File.dirname(__FILE__)
require 'ruby_screen/preferences_loader'

%w[description parser executer].each { |f| require "ruby_screen/configuration/#{f}" }

module RubyScreen
  def self.process(arguments)
    preferences_hash = PreferencesLoader.load
    description = Configuration::Parser.new(arguments, preferences_hash).parse
    Configuration::Executer.new(description)
  end
end
