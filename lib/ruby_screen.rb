$:.unshift File.dirname(__FILE__)
require 'preferences_loader'

module RubyScreen
  def self.process(arguments)
    PreferencesLoader.load
  end
end
