module RubyScreen::Configuration
  class Executer
    def initialize(configuration)
      @configuration = configuration

      File.open(configuration_file_path, "w") do |f|
        f.print configuration_string
      end

      Dir.chdir @configuration.initial_directory if @configuration.initial_directory
      Kernel.exec "screen -c #{configuration_file_path}"
    end

    protected

    def configuration_string
      build_customizations_string + numbered_windows + numberless_windows
    end

    def configuration_file_path
      ENV["HOME"] + "/.ruby-screen.compiled_configuration"
    end

    def build_customizations_string
      @configuration.customizations.inject("") do |buffer, (k, v)|
        buffer << "#{k} #{v}\n"
      end
    end

    def numbered_windows
      @configuration.numbered_windows.keys.sort.inject("") do |buffer, window_number|
        window_definition = @configuration.numbered_windows[window_number]

        buffer << "screen"
        window_title_setting(buffer, window_definition)
        buffer << " #{window_number}"
        window_command_setting(buffer, window_definition)

        buffer << "\n"
      end
    end

    def numberless_windows
      @configuration.numberless_windows.inject("") do |buffer, window_definition|
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
