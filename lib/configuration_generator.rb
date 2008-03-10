module RubyScreen
  class ConfigurationGenerator
    def initialize(arguments, preferences_hash)
      @arguments, @preferences_hash = arguments, preferences_hash
      @configuration = Configuration.new

      Hash.class_eval { include PreferencesHashMethods }
    end

    def generate
      settings_array = [@preferences_hash]
      non_nested_arguments = []

      @arguments.each do |argument|
        if @preferences_hash.has_nested_configuration?(argument)
          nested_configuration = @preferences_hash[argument]
          settings_array << nested_configuration
          @preferences_hash = nested_configuration
        else non_nested_arguments << argument
        end
      end

      settings_array.each do |settings_hash|
        @preferences_hash = clear_nested_configurations(settings_hash)

        extract_special_settings
        extract_windows
        add_customizations
      end

      unless non_nested_arguments.empty?
        initial_directory = @configuration.initial_directory
        joined_arguments = non_nested_arguments.join("/")
        if initial_directory && initial_directory.split("").last == "/"
          @configuration.initial_directory = initial_directory + joined_arguments
        elsif initial_directory
          @configuration.initial_directory = initial_directory + "/" + joined_arguments
        else
          @configuration.initial_directory = joined_arguments
        end
      end
    end

    protected

    def clear_nested_configurations(hash)
      hash.reject { |k,v| v.is_a?(Hash) }
    end

    def extract_special_settings
      ["initial_directory", "shell_executable"].each { |setting| extract_special_setting(setting) }
    end

    def extract_special_setting(setting)
      if @preferences_hash.has_key?(setting)
        setter_method = "#{setting}=".to_sym
        setting_value = @preferences_hash.delete(setting)
        @configuration.send(setter_method, setting_value)
      end
    end

    def extract_windows
      if @preferences_hash.has_key?("windows")
        @preferences_hash["windows"].each { |w| @configuration.add_window(w) }
        @preferences_hash.delete("windows")
      end
    end

    def add_customizations
      @preferences_hash.each { |k, v| @configuration.add_customization(k, v) }
    end
  end

  module PreferencesHashMethods
    def has_nested_configuration?(configuration_name)
      self.has_key?(configuration_name) && self[configuration_name].is_a?(Hash)
    end
  end
end
