module RubyScreen::Configuration
  class Parser
    def initialize(arguments, preferences_hash)
      @iterator = Iterator.new(arguments, preferences_hash)
      @description = Description.new
    end

    def parse
      @iterator.each_applicable_configuration_block { |block| BlockParser.new(block, @description) }
      include_extra_arguments_as_directories unless @iterator.arguments.empty?

      @description
    end

    protected

    def include_extra_arguments_as_directories
      working_directory = @description.working_directory || ""
      working_directory << "/" unless working_directory.empty? || working_directory[-1].chr == "/"
      @description.working_directory = working_directory + @iterator.arguments.join("/")
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
    def initialize(preferences_hash, description)
      @preferences_hash, @description = preferences_hash, description

      process_directories
      extract_windows
      add_customizations
    end

    protected

    def process_directories
      if @preferences_hash.has_key?("working_directory")
        @description.working_directory = @preferences_hash.delete("working_directory")
      elsif @preferences_hash.has_key?("relative_directory")
        @description.append_directory(@preferences_hash.delete("relative_directory"))
      end
    end

    def extract_windows
      if @preferences_hash.has_key?("windows")
        @preferences_hash["windows"].each { |w| @description.add_window(w) }
        @preferences_hash.delete("windows")
      end
    end

    def add_customizations
      @preferences_hash.each do |k, v|
        # Necessary because YAML load takes values line 'on' or 'off' that aren't quoted and turn them into booleans
        if is_a_boolean?(v)
          v = (v ? "on" : "off")
        end

        @description.add_customization(k, v)
      end
    end

    def is_a_boolean?(value)
      value.is_a?(TrueClass) || value.is_a?(FalseClass)
    end
  end
end
