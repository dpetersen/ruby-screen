module RubyScreen::Configuration::Parser
  module NestingHash
    def self.extended(object)
      object.instance_variable_set(:@nesting_lookup, {})
      object.send(:build_nesting_lookup, object)
    end

    def find_nested_key(string)
      @nesting_lookup[string]
    end

    protected

    def build_nesting_lookup(hash, stack = [])
      hash.find_all { |k, v| v.is_a?(Hash) }.each do |a|
        add_nested_path(stack, *a)
      end
    end

    def add_nested_path(stack, name, hash)
      raise DuplicateKeyException.new(name) if @nesting_lookup.has_key?(name)

      path = stack.dup <<  name
      @nesting_lookup[name] = path

      build_nesting_lookup(hash, path)
    end
  end

  class ::DuplicateKeyException < StandardError
    def initialize(key)
      @key = key
    end

    attr_reader :key
  end
end
