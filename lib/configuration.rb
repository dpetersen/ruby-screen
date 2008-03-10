module RubyScreen
  class Configuration
    attr_reader :customizations, :numbered_windows, :numberless_windows
    attr_accessor :initial_directory, :shell_executable

    def initialize
      @customizations = {}
      @numberless_windows = []
      @numbered_windows = {}
    end

    def add_customization(key, value)
      @customizations.store(key, value)
    end

    def add_window(options)
      options.include?(:number) ? add_numbered_window(options) : add_numberless_window(options)
    end

    protected

    def add_numberless_window(options)
      @numberless_windows << options
    end

    def add_numbered_window(options)
      number = options.delete(:number)
      @numbered_windows[number] = options
    end
  end
end