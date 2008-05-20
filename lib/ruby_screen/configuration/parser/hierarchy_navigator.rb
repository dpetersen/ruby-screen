module RubyScreen::Configuration::Parser
  class HierarchyNavigator
    def initialize(argument, preferences_hash)
      @argument, @preferences_hash = argument, preferences_hash
      @all_nested_configurations = {}

      build_nesting_hash(@preferences_hash)
    end

    def hierarchy
      @all_nested_configurations[@argument.first] || []
    end

    protected

    def build_nesting_hash(hash, stack = [])
      hash.find_all { |k, v| v.is_a?(Hash) }.each do |a|
        add_nested_configuration(stack, *a)
      end
    end

    def add_nested_configuration(stack, name, hash)
      if @all_nested_configurations.has_key?(name)
        Kernel.abort("There are multiple configurations named '#{name}'.  You cannot have duplicate names!")
      end

      path = stack.dup <<  name
      @all_nested_configurations[name] = path

      build_nesting_hash(hash, path)
    end
  end
end
