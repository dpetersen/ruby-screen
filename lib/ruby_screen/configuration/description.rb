module RubyScreen::Configuration
  class Description
    attr_reader :customizations, :numbered_windows, :numberless_windows
    attr_accessor :working_directory

    def initialize
      @customizations = {}
      @numberless_windows = []
      @numbered_windows = {}
    end

    def append_directory(directory)
      if @working_directory
        @working_directory += "/" + strip_slashes(directory)
      else
        @working_directory = directory
      end
    end

    def add_customization(key, value)
      @customizations.store(key, value)
    end

    def add_window(options)
      options.include?(:number) ? add_numbered_window(options) : add_numberless_window(options)
    end

    def to_screen_configuration
      Generator.new(self).to_screen_configuration
    end

    protected

    def strip_slashes(s)
      s.gsub!(/^\//, "")
      s.gsub!(/\/$/, "")
      s
    end

    def add_numberless_window(options)
      @numberless_windows << options
    end

    def add_numbered_window(options)
      number = options.delete(:number)
      @numbered_windows[number] = options
    end
  end
end
