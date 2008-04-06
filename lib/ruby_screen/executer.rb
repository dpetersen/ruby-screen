module RubyScreen
  class Executer
    def initialize(description)
      File.open(configuration_file_path, "w") { |f| f.print description.to_screen_configuration }

      Dir.chdir(description.initial_directory) if description.initial_directory
      Kernel.exec "screen -c #{configuration_file_path}"
    end

    protected

    def configuration_file_path
      ENV["HOME"] + "/.ruby-screen.compiled_configuration"
    end
  end
end
