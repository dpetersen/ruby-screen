module RubyScreen::Configuration
  class Generator
    def initialize(arguments, preferences_hash)
      @iterator = Iterator.new(arguments, preferences_hash)
      @configuration = Description.new
    end

    def generate
      @iterator.each_applicable_configuration_block { |block| BlockParser.new(block, @configuration) }
      include_extra_arguments_as_directories unless @iterator.arguments.empty?

      @configuration
    end

    protected

    def include_extra_arguments_as_directories
      initial_directory = @configuration.initial_directory || ""
      initial_directory << "/" unless initial_directory.empty? || initial_directory[-1].chr == "/"
      @configuration.initial_directory = initial_directory + @iterator.arguments.join("/")
    end
  end

  class Iterator
    attr_reader :arguments

    def initialize(arguments, preferences_hash)
      @arguments, @preferences_hash = arguments, preferences_hash
    end

    def each_applicable_configuration_block(&block)
      yield current_preferences_block

      until preferences_exhausted?
        @preferences_hash = @preferences_hash[@arguments.first]
        @arguments.shift
        yield current_preferences_block
      end
    end

    protected

    def preferences_exhausted?
      @arguments.empty? || !has_nested_configuration?(@preferences_hash, @arguments.first)
    end

    def has_nested_configuration?(hash, configuration_name)
      hash.has_key?(configuration_name) && hash[configuration_name].is_a?(Hash)
    end

    def current_preferences_block
      @preferences_hash.reject { |k,v| v.is_a?(Hash) }
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
end
