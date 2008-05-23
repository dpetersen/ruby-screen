module RubyScreen::Configuration
  class Description
    attr_reader :customizations, :numbered_windows, :numberless_windows, :working_directory

    def initialize
      @customizations = {}
      @numberless_windows = []
      @numbered_windows = {}
      @working_directory = ""
    end

    def working_directory=(directory)
      process_directory(directory)
    end

    def append_directory(directory)
      process_directory(directory, !@working_directory.empty?)
    end

    def add_customization(key, value)
      @customizations.store(key, value)
    end

    def add_window(options)
      options.include?("number") ? add_numbered_window(options) : add_numberless_window(options)
    end

    def to_screen_configuration
      Generator.new(self).to_screen_configuration
    end

    protected

    def process_directory(directory, append = false)
      @working_directory =
        if directory[0].chr == "~"
          File.expand_path(directory)
        elsif append
          @working_directory + "/" + strip_slashes(directory)
        else
          directory
        end
    end

    def strip_slashes(s)
      s.gsub!(/^\//, "")
      s.gsub!(/\/$/, "")
      s
    end

    def add_numberless_window(options)
      @numberless_windows << options
    end

    def add_numbered_window(options)
      number = options.delete("number")
      @numbered_windows[number] = options
    end
  end
end
