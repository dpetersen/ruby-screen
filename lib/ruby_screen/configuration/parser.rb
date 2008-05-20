$:.unshift File.dirname(__FILE__)
require 'parser/nesting_hash'
require 'parser/iterator'
require 'parser/block_processor'

module RubyScreen::Configuration
  module Parser
    def self.parse(arguments, preferences_hash)
      description = Description.new

      begin
        preferences_hash.extend(NestingHash)
      rescue DuplicateKeyException => e
        Kernel.abort("There are multiple configurations named '#{e.key}'.  You cannot have duplicate names!")
      end

      full_configuration_path = preferences_hash.find_nested_key(arguments.first) || []

      iterator = Iterator.new(full_configuration_path, preferences_hash)
      iterator.each_applicable_configuration_block { |block| BlockProcessor.new(block, description) }

      handle_additional_arguments_as_directories(arguments, description)

      description
    end

    protected

    def self.handle_additional_arguments_as_directories(arguments, description)
      if arguments.length > 1
        arguments.slice!(1..-1).each { |s| description.append_directory(s) }
      end
    end
  end
end
