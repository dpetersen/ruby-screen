$:.unshift File.dirname(__FILE__)
require 'parser/iterator'
require 'parser/block_processor'

module RubyScreen::Configuration
  module Parser
    def self.parse(arguments, preferences_hash)
      @iterator = Iterator.new(arguments, preferences_hash)
      @description = Description.new

      @iterator.each_applicable_configuration_block { |block| BlockProcessor.new(block, @description) }
      include_extra_arguments_as_directories unless @iterator.arguments.empty?

      @description
    end

    protected

    def self.include_extra_arguments_as_directories
      @iterator.arguments.each { |s| @description.append_directory(s) }
    end
  end
end
