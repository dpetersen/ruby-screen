$:.unshift File.dirname(__FILE__)
require 'parser/hierarchy_navigator'
require 'parser/iterator'
require 'parser/block_processor'

module RubyScreen::Configuration
  module Parser
    def self.parse(arguments, preferences_hash)
      description = Description.new

      handle_additional_arguments(arguments, description)

      full_configuration_path = HierarchyNavigator.new(arguments, preferences_hash).hierarchy

      iterator = Iterator.new(full_configuration_path, preferences_hash)
      iterator.each_applicable_configuration_block { |block| BlockProcessor.new(block, description) }

      description
    end

    protected

    def self.handle_additional_arguments(arguments, description)
      if arguments.length > 1
        arguments.slice!(1..-1).each { |s| description.append_directory(s) }
      end
    end
  end
end
