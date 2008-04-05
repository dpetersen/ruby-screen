$:.unshift File.dirname(__FILE__)
require 'ruby_screen/preferences_loader'

%w[description generator executer].each { |f| require "ruby_screen/configuration/#{f}" }

module RubyScreen
  def self.process(arguments)
    preferences_hash = PreferencesLoader.load
    description = Configuration::Generator.new(arguments, preferences_hash).generate
    Configuration::Executer.new(description)
  end
end
