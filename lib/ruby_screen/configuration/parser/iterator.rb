module RubyScreen::Configuration::Parser
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
end
