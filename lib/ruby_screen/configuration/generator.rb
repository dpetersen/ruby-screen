module RubyScreen::Configuration
  class Generator
    def initialize(description)
      @description = description
    end

    def to_screen_configuration
      build_customizations_string + numbered_windows + numberless_windows
    end

    protected

    def build_customizations_string
      @description.customizations.inject("") do |buffer, (k, v)|
        buffer << "#{k} #{v}\n"
      end
    end

    def numbered_windows
      @description.numbered_windows.keys.sort.inject("") do |buffer, window_number|
        window_definition = @description.numbered_windows[window_number]

        buffer << "screen"
        window_title_setting(buffer, window_definition)
        buffer << " #{window_number}"
        window_command_setting(buffer, window_definition)

        buffer << "\n"
      end
    end

    def numberless_windows
      @description.numberless_windows.inject("") do |buffer, window_definition|
        buffer << "screen"
        window_title_setting(buffer, window_definition)
        window_command_setting(buffer, window_definition)

        buffer << "\n"
      end
    end

    def shell
      @shell ||= ENV["SHELL"]
    end

    def window_title_setting(buffer, window_definition)
      buffer << " -t #{window_definition['title']}" if window_definition.has_key?("title")
    end

    def window_command_setting(buffer, window_definition)
      buffer << " sh -c \"#{window_definition['command']}; #{shell}\"" if window_definition.has_key?("command")
    end
  end
end
