module RubyScreen::Configuration
  class Generator
    def initialize(arguments, preferences_hash)
      @arguments, @preferences_hash = arguments, preferences_hash
      @configuration = Description.new

      Hash.class_eval { include PreferencesHashMethods }
    end

    def generate
      recurse_preferences_hash_with_attributes
      include_extra_arguments_as_directories(@arguments) unless @arguments.empty?
    end

    protected

    def recurse_preferences_hash_with_attributes
      @arguments.unshift nil #TODO: I should sort this out at some point, this is ridiculous

      begin
        @arguments.shift
        process_configuration_block(@preferences_hash)

        if @preferences_hash.has_nested_configuration?(@arguments.first)
          @preferences_hash = @preferences_hash[@arguments.first]
        else break
        end
      end until @arguments.empty?
    end

    def process_configuration_block(configuration_block)
      BlockParser.new(
        clear_nested_configurations(configuration_block),
        @configuration)
    end

    def clear_nested_configurations(hash)
      hash.reject { |k,v| v.is_a?(Hash) }
    end

    def include_extra_arguments_as_directories(non_nested_arguments)
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

  class BlockParser
    def initialize(preferences_hash, configuration)
      @preferences_hash, @configuration = preferences_hash, configuration

      extract_special_settings
      extract_windows
      add_customizations
    end

    protected

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
