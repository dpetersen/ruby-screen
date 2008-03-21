require 'yaml'

module RubyScreen
  class PreferencesLoader
    def self.load
      YAML.load_file(default_preferences_file)
    end

    protected

    def self.default_preferences_file
      "#{ENV['HOME']}/.ruby-screen.yml"
    end
  end
end
