require 'yaml'

module RubyScreen
  class PreferencesLoader
    DEFAULT_PREFERENCES_FILE = "$HOME/.ruby-screen.yml"

    def self.load
      YAML.load_file(DEFAULT_PREFERENCES_FILE)
    end
  end
end
