require 'erb'
require 'yaml'

module RubyScreen
  class PreferencesLoader
    def self.load
      begin
        configuration_string = IO.read(default_preferences_file)
        processed_string = ERB.new(configuration_string).result
        YAML.load(processed_string)
      rescue
        Kernel.abort <<-EOS
There was a problem loading your preferences file.  I expect you to have an
environment variable called "HOME" which holds the path to your home directory,
and in that directory there should be the YAML file ".ruby-screen.yml"
        EOS
      end
    end

    protected

    def self.default_preferences_file
      "#{ENV['HOME']}/.ruby-screen.yml"
    end
  end
end
