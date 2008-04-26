require 'tempfile'

module RubyScreen
  class Executer
    def initialize(description)
      File.open(configuration_file_path, "w") { |f| f.print description.to_screen_configuration }

      change_directory(description.initial_directory) if description.initial_directory
      Kernel.exec "screen -c #{configuration_file_path}"
    end

    protected

    def change_directory(directory)
      if File.exists?(directory) && File.directory?(directory)
        Dir.chdir(directory)
      else
        Kernel.abort("The initial directory you provided, '#{directory}', either does not exist or is not a directory.")
      end
    end

    def configuration_file_path
      Dir.tmpdir + "/.ruby-screen.compiled_configuration"
    end
  end
end
